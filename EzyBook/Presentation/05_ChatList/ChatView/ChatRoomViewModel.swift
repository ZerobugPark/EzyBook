//
//  ChatRoomViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import SwiftUI
import Combine

final class ChatRoomViewModel: ViewModelType {
    
    private var socketService: SocketService
    private let roomID: String
    private let opponentNick: String
    
    private var userID: String = ""
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    private var chatMessages: [ChatMessageEntity] = []
    private var scale: CGFloat = 0
    private let chatListUseCase :DefaultChatListUseCase
    private let chatRealmUseCase: DefaultChatRealmUseCase
    private let profileLookUpUseCase: DefaultProfileLookUpUseCase
    private let profileSearchUseCase: DefaultProfileSearchUseCase
    private let imageLoader: DefaultLoadImageUseCase
    
    init(
        socketService: SocketService,
        roomID: String,
        opponentNick: String,
        chatListUseCase: DefaultChatListUseCase,
        chatRealmUseCase: DefaultChatRealmUseCase,
        profileLookUpUseCase: DefaultProfileLookUpUseCase,
        profileSearchUseCase: DefaultProfileSearchUseCase,
        imageLoader: DefaultLoadImageUseCase
    ) {

        self.socketService = socketService
        self.roomID = roomID
        self.opponentNick = opponentNick
        self.chatListUseCase = chatListUseCase
        self.chatRealmUseCase = chatRealmUseCase
        self.profileLookUpUseCase = profileLookUpUseCase
        self.profileSearchUseCase = profileSearchUseCase
        self.imageLoader = imageLoader
        
       
        transform()
    }
    
    
    deinit {
        socketService.disconnect()
    }
}

// MARK: Input/Output
extension ChatRoomViewModel {
    
    struct Input {  }
    
    struct Output {
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
        
        var unknownedUser: Bool = false
        var opponentProfile: ProfileLookUpModel = .skeleton
        
        var chatList: [ChatMessageEntity] = []
    }
    
    
    private var opponentID: String {
        output.opponentProfile.userID
    }
    
    func transform() {}
    
  
    private func startEnterChatRoomFlow() {
        Task {
            await handleEnterChatRoom()
        }
    }
    
    
    ///[채팅방 진입 시]
    ///1. 프로펄 조회
    ///2. 로컬 DB  채팅 내역 조회
    ///3. 서버에서 최신 채팅 내역 요청
    ///4. 데이터 저장 및 UI 업데이트
    ///5. 소켓 연결
    ///-> 데이터 동기화로 인하여 WebSocket연결이 지연 될 수 있기 때문에, 소켓 연결 후 최신 채팅 내역 한번 더 요청
    
    
    // MARK: - Entry Point
    private func handleEnterChatRoom() async {
        loadProfileLookup()
        
        // 1) Realm 데이터 즉시 로드 (초기 UI)
        await loadInitialChatData()
        
        // 2) 서버 최신 여부 동기화 (백그라운드)
        await syncChatListIfNeeded()
        
        // 3) 소켓 설정 및 연결
        configureSocket()
        socketService.connect()
    }

    
    // MARK: - Initial Load (Realm → UI 즉시 표시)
    private func loadInitialChatData() async {
        await MainActor.run {
            let messages = chatRealmUseCase.excuteFetchChatList(
                roomID: roomID,
                before: nil,
                limit: 30,
                opponentID: opponentID
            )
            output.chatList = messages
        }
    }


    // MARK: - Sync Logic (서버와 최신 여부 비교 후 새 메시지 동기화)
    private func syncChatListIfNeeded() async {
        guard let lastLocalMessage = await loadLocalLastMessage() else {
            // Realm도 비어있으면 전체 조회
            await requestChatList()
            return
        }
        
        do {
            let serverLatest = try await fetchChatListFromServer(lastLocalMessage.createdAt)
            guard !serverLatest.isEmpty else { return }
            
            await saveAndLoadChatList(serverLatest)
        } catch {
            print("syncChatListIfNeeded error: \(error)")
        }
    }
    
    // MARK: - Socket Configuration
    private func configureSocket() {
        socketService.onConnect = { [weak self] in
            guard let self else { return }
            Task {
                await self.syncChatListIfNeeded()
            }
        }
        
        socketService.onMessageReceived = { [weak self] message in
            guard let self else { return }
            Task {
                await self.handleIncomingMessage(message)
            }
        }
    }

    

    // MARK: - Handle Incoming Message (실시간 소켓 메시지 append)
    private func handleIncomingMessage(_ message: ChatMessageEntity) async {
        await MainActor.run {
            // Realm 저장
            chatRealmUseCase.executeSaveData(chatList: [message])
            
            // UI append (중복 방지)
            if !output.chatList.contains(where: { $0.chatID == message.chatID }) {
                output.chatList.append(message)
            }
        }
    }

    // MARK: - Local Realm Helpers
    /// 최근 메시지 1개 (서버 동기화 기준)
    private func loadLocalLastMessage() async -> ChatMessageEntity? {
        await MainActor.run {
            return chatRealmUseCase.excutefetchLatestMessage(
                roodID: roomID,
                opponentID: opponentID
            )
        }
    }
    
    // MARK: - Chat List Request (서버 → Realm 저장 → append or 전체 교체)
    private func requestChatList(_ next: String? = nil) async {
        do {
            let chatList = try await fetchChatListFromServer(next)
            
            if next == nil {
                // 전체 로드 (초기 진입 or Realm 비었을 때)
                await MainActor.run {
                    chatRealmUseCase.executeSaveData(chatList: chatList)
                    let messages = chatRealmUseCase.excuteFetchChatList(
                        roomID: roomID,
                        before: nil,
                        limit: 30,
                        opponentID: opponentID
                    )
                    output.chatList = messages
                }
            } else {
                // 추가 로드 (append)
                await saveAndLoadChatList(chatList)
            }
        } catch {
            print("requestChatList error: \(error)")
        }
    }

    /// 네트워크 순수 호출
    private func fetchChatListFromServer(_ next: String? = nil) async throws -> [ChatMessageEntity] {
        let data = try await chatListUseCase.execute(id: roomID, next: next)
        return data.map { $0.toEnity() }
    }

    /// Realm 저장 후 UI append
    private func saveAndLoadChatList(_ chatList: [ChatMessageEntity]) async {
        guard !chatList.isEmpty else { return }
        
        await MainActor.run {
            chatRealmUseCase.executeSaveData(chatList: chatList)
            
            let newMessages = chatList.filter { newMsg in
                !output.chatList.contains { $0.chatID == newMsg.chatID }
            }
            output.chatList.append(contentsOf: newMessages)
        }
    }


    
    ///프로필 조회
    private func loadProfileLookup() {
        Task {
            do {
                let data = try await profileLookUpUseCase.execute()
                
                /// 상대방과 나를 비교하기 위한 UserID
                userID = data.userID
                print(userID)
                
                let opponentData = try await profileSearchUseCase.execute(opponentNick)
                
                guard !opponentData.isEmpty else {
                    await MainActor.run {
                        output.unknownedUser = true
                    }
                    return
                }
                
                let profileImage: UIImage
              
                if let url = opponentData[0].profileImage {
                    profileImage = try await imageLoader.execute(url)
                } else  {
                    profileImage = UIImage(resource: .tabBarProfileFill)
                }
                
                await MainActor.run {
                    output.opponentProfile = ProfileLookUpModel(from: opponentData[0], profileImage: profileImage)
                }
                
                
            } catch let error as APIError {
                await MainActor.run {
                    output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
                }
            }
        }
    }
    
    
}

// MARK: Action
extension ChatRoomViewModel {
    
    enum Action {
        case startChat
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .startChat:
            startEnterChatRoomFlow()
        }
    }
    
    
}


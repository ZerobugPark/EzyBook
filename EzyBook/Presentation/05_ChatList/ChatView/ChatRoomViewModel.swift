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
    
    
    
    ///[채팅방 진입 시]
    ///1. 프로펄 조회
    ///2. 로컬 DB에서 채팅 내역 조회
    ///3. 서버에서 최신 채팅 내역 요청
    ///4. 데이터 저장 및 UI 업데이트
    ///5. 소켓 연결
    ///-> 데이터 동기화로 인하여 WebSocket연결이 지연 될 수 있기 때문에, 소켓 연결 후 최신 채팅 내역 한번 더 요청
    private func handleEnterChatRoom() {
        
        /// 내 프로필 및 상대방 프로필
        loadProfileLookup()


        //// Realm에서 메시지 가져오기
        loadLocalMessages()
        
        /// 서버에서 채팅 내역 요청
        if output.chatList.isEmpty {
            /// 렘에 비어있으면 서버에서 전체 데이터 조회
            requestChatList()
        } else {
            /// 렘이 비어있지 않다면 마지막 메시지만 비교
            requesLastChatMessage()
        }
        
  
        
        socketService.onConnect = { [weak self] in
            
            guard let self else { return }
            requesLastChatMessage()
        }

        
        socketService.onMessageReceived = { [weak self] message in
            
            guard let self else { return }
            
            Task {
                await MainActor.run {
                    let chat: [ChatMessageEntity] = [message]
                    self.chatRealmUseCase.executeSaveData(chatList: chat)
                }
            }
            
            self.chatMessages.append(message)
        }
        
        
        
        
        
        socketService.connect()
        

     
    }
    
    /// 렘에서 최근 메시지 조회
    private func loadLocalMessages() {
        
        Task {
            await MainActor.run {
                let list = chatRealmUseCase.excutefetchLatestMessage(roodID: roomID, opponentID: opponentID)
                output.chatList = list
            }
        }
        
        
        
    }
    
    /// 서버에서 마지막 채팅 내역 조회
    private func requesLastChatMessage() {
        guard let date = output.chatList.last?.createdAt else {
            return
        }
        requestChatList(date)
    }

    

    /// 채팅 내역 조회
    private func requestChatList(_ next: String? = nil) {
        
        Task {
            do {
                let data = try await chatListUseCase.execute(id: roomID, next: next)

                
                
                /// 렘에서는 isMine을 저장하지않음 (데이터 무결성을 해침)
                /// A로 로그인하고, 동일한 기기로 B로 로그인한다면? 둘다 isMine은 true지만 실제 로그인 유저에 따라 다를 수 있음
                /// 기기는 Realm을 공통으로 관리하기 때문에
                let chatList = data.map { $0.toEnity() }
                
                // 렘 로직 추가
                await MainActor.run {
                    chatRealmUseCase.executeSaveData(chatList: chatList)
                }
                
                
            } catch {
                print(error)
            }
        }
        
        
    }
    
    ///프로필 조회
    private func loadProfileLookup() {
        Task {
            do {
                let data = try await profileLookUpUseCase.execute()
                
                /// 상대방과 나를 비교하기 위한 UserID
                userID = data.userID
                
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
            handleEnterChatRoom()
        }
    }
    
    
}


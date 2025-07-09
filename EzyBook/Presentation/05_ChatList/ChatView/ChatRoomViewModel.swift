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
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    private var chatMessages: [ChatMessageEntity] = []
    private var scale: CGFloat = 0
    private let chatListUseCase :DefaultChatListUseCase
    private let chatRealmUseCase: DefaultChatRealmUseCase
    private let profileLookUpUseCase: DefaultProfileLookUpUseCase
    private let profileSearchUseCase: DefaultProfileSearchUseCase
    
    init(
        socketService: SocketService,
        roomID: String,
        opponentNick: String,
        chatListUseCase: DefaultChatListUseCase,
        chatRealmUseCase: DefaultChatRealmUseCase,
        profileLookUpUseCase: DefaultProfileLookUpUseCase,
        profileSearchUseCase: DefaultProfileSearchUseCase
    ) {

        self.socketService = socketService
        self.roomID = roomID
        self.opponentNick = opponentNick
        self.chatListUseCase = chatListUseCase
        self.chatRealmUseCase = chatRealmUseCase
        self.profileLookUpUseCase = profileLookUpUseCase
        self.profileSearchUseCase = profileSearchUseCase
        
        self.socketService.onMessageReceived = { [weak self] message in
            
            Task {
                await MainActor.run {
                    let chat: [ChatMessageEntity] = [message]
                    chatRealmUseCase.executeSaveData(chatList: chat)
                }
            }
            
            self?.chatMessages.append(message)
        }
       
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
       
    }
    
    func transform() {}
    
    
    
    ///[채팅방 진입 시]
    ///1. Realm 마지막 메시지 확인
    ///2. 서버 마지막 메시지 fetch
    ///3. 동일하면 → Realm만 UI에 사용
    ///4. 다르면 → 이후 메시지 fetch → Realm 업데이트 → UI 업데이트
    private func handleConnectSocket() {
        socketService.connect()
        
        /// Realm 마지막 메시지 확인
        if let lastLocalMessage = chatRealmUseCase.excuteLastChatMessage(roodID: roomID) {
            /// 서버 패치
            requestChatList(lastLocalMessage.createdAt)
        } else {
            /// 서버 패치
            requestChatList()
        }
        
        /// 내 프로필과, 상대방의 프로필은 언제가져오는게 좋지?
        /// 내 프로필 조회
        
        
        loadProfileLookup()
        //print(opponentNick) //상대방 ID
        ///
        /// UI 업데이트 로직 추가
        
     
    }
    

    private func loadProfileLookup() {
        Task {
            do {
                let data = try await profileLookUpUseCase.execute()
                print("profile", data)
                
                let opponentData = try await profileSearchUseCase.execute(opponentNick)
                print("opponentData", opponentData)
            } catch let error as APIError {
                await MainActor.run {
                    output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
                }
            }
        }
    }
    
    private func requestChatList(_ next: String? = nil) {
        
        Task {
            do {
                let data = try await chatListUseCase.execute(id: roomID, next: next)
                
                let chatList = data.map {
                    
                    /// 렘에서는 isMine을 저장하지않음 (데이터 무결성을 해침)
                    /// A로 로그인하고, 동일한 기기로 B로 로그인한다면? 둘다 isMine은 true지만 실제 로그인 유저에 따라 다를 수 있음
                    /// 기기는 Realm을 공통으로 관리하기 때문에
                    ChatMessageEntity(
                        chatID: $0.chatId,
                        content: $0.content,
                        createdAt: $0.createdAt,
                        files: $0.files,
                        roomID: $0.roomId,
                        sender: ChatMessageEntity.Sender(
                            userID: $0.sender.userID,
                            nick: $0.sender.nick
                        ), isMine: false
                    )
                    
                }
                
                // 렘 로직 추가
                await MainActor.run {
                    chatRealmUseCase.executeSaveData(chatList: chatList)
                }
                
                
            } catch {
                print(error)
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
            handleConnectSocket()
        }
    }
    
    
}


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
    private let opponentID: String
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    private var chatMessages: [ChatMessageEntity] = []
    private var scale: CGFloat = 0
    private var chatListUseCase :DefaultChatListUseCase
    private var chatRealmUseCase: DefaultChatRealmUseCase
    
    init(
        socketService: SocketService,
        roomID: String,
        opponentID: String,
        chatListUseCase: DefaultChatListUseCase,
        chatRealmUseCase: DefaultChatRealmUseCase
    ) {

        self.socketService = socketService
        self.roomID = roomID
        self.opponentID = opponentID
        self.chatListUseCase = chatListUseCase
        self.chatRealmUseCase = chatRealmUseCase
        
        self.socketService.onMessageReceived = { [weak self] message in
            print("메시지:",message)
            self?.chatMessages.append(message)
        }
       
        transform()
    }
    
    
    deinit {
        print("Here")
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
            print("here")
            print(lastLocalMessage)
            
            /// 서버 패치
            requestChatList(lastLocalMessage.createdAt)
        } else {
            print("here2")
            /// 서버 패치
            requestChatList()
        }
        
        /// 내 프로필과, 상대방의 프로필은 언제가져오는게 좋지?
        /// 그냥 주입시켜버릴까?
        
        print(opponentID)
        ///
        /// UI 업데이트 로직 추가
        

     
    }
    

    private func requestChatList(_ next: String? = nil) {
        
        Task {
            do {
                let data = try await chatListUseCase.execute(id: roomID, next: next)
                // 렘 로직 추가
                await MainActor.run {
                    chatRealmUseCase.executeSaveData(chatList: data)
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


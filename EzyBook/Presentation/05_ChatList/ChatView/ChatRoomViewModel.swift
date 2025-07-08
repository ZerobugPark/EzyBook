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
        chatListUseCase: DefaultChatListUseCase,
        chatRealmUseCase: DefaultChatRealmUseCase
    ) {

        self.socketService = socketService
        self.roomID = roomID
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
    
    
    private func handleConnectSocket() {
        socketService.connect()
        
        
        if let lastLocalMessage = chatRealmUseCase.excuteLastChatMessage(roodID: roomID) {
            requestChatList(lastLocalMessage.createdAt)
        } else {
            requestChatList()
        }

        

     
    }
    

    private func requestChatList(_ next: String? = nil) {
        
        Task {
            do {
                let data = try await chatListUseCase.execute(id: roomID, next: nil)
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


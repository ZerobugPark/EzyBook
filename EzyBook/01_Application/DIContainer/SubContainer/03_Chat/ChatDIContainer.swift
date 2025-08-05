//
//  ChatDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 7/25/25.
//

import Foundation

final class ChatDIContainer {
    
    
    private let networkService: DefaultNetworkService
    private let commonDIContainer: CommonDIContainer
    private let socketService: SocketServicePool
    
    init(networkService: DefaultNetworkService, commonDIContainer: CommonDIContainer, storage: TokenStorage) {
        self.networkService = networkService
        self.commonDIContainer = commonDIContainer
        self.socketService = SocketServicePool(keyChain: storage)
    }
    
    
}

// MARK: Maek Chat UseCase
extension ChatDIContainer {
    
    
    // MARK: ChatList Bundle
    private func makeChatListUseCases() -> ChatListUseCases {
        ChatListUseCases(
            sendMessages: makeSendMessageUseCase(),
            saveRealmMessages: makeSaveChatMessageUseCase(),
            fetchRealmLatestMessage: makeFetchLatestChatMessageUseCase(),
            fetchRealmMessageList: makeFetchChatMessageListUseCase(),
            fetchRemoteMessage: makeFetchRemoteChatMessagesUseCase()
        )
    }
    
    private func makeSendMessageUseCase() -> SendMessageUseCase {
        DefaultChatSendMessageUseCase(repo: makeChatRepository())
    }
    
    private func makeSaveChatMessageUseCase() -> SaveChatMessageUseCase {
        DefaultRealmSaveChatMessageUseCase(repo:  makeChatMessageRealmRepository())
    }
    
    /// 가장 최근 메시지 조회
    private func makeFetchLatestChatMessageUseCase() -> FetchLatestChatMessageUseCase {
        DefaultRealmFetchLatestChatMessageUseCase(repo:  makeChatMessageRealmRepository())
    }
    
    
    /// 메시지 내역 조회
    private func makeFetchChatMessageListUseCase() -> FetchChatMessageListUseCase {
        DefaultRealmFetchChatMessageListUseCase(repo: makeChatMessageRealmRepository())
    }
    

    
    // MARK: 채팅 목록
    private func makeFetchRealmChatRoomListUseCase() -> FetchRealmChatRoomListUseCase {
        DefaultFetchRealmChatRoomListUseCase(repo: makeChatMessageRealmRepository())
    }

    private func makeChatRemoteRoomListUseCase() -> ChatRemoteRoomListUseCase {
        DefaultChatRemoteRoomListUseCase(repo: makeChatRepository())
    }
    
    // MARK: Common
    private func makeFetchRemoteChatMessagesUseCase() -> FetchRemoteChatMessagesUseCase {
        DefaultFetchRemoteChatMessagesUseCase(repo: makeChatRepository())
    }
    
    
}


// MARK: Data
extension ChatDIContainer {
    

    private func makeChatMessageRealmRepository() -> DefaultChatRoomRealmRepository {
        DefaultChatRoomRealmRepository()
    }
    
    
    private func makeChatRepository() -> DefaultChatRepository {
        DefaultChatRepository(networkService: networkService)
    }
}



// MARK: Make ViewModel
extension ChatDIContainer {
    
    func makeChatRoomViewModel(roomID: String, opponentNick: String) -> ChatRoomViewModel {
        
        let socketService: SocketService = socketService.service(for: roomID)
        
        return ChatRoomViewModel(
            socketService: socketService,
            roomID: roomID,
            chatUseCases: makeChatListUseCases(),
            opponentNick: opponentNick
        )
    }
    
    
    func makeChatListViewModel() -> ChatListViewModel {
        ChatListViewModel(
            fetchChatListUseCase:makeFetchRealmChatRoomListUseCase(),
            chatListUseCase: makeChatRemoteRoomListUseCase()
        )
    }
   
    
}

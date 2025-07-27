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
    
    private func makeFetchLatestChatMessageUseCase() -> FetchLatestChatMessageUseCase {
        DefaultRealmFetchLatestChatMessageUseCase(repo:  makeChatMessageRealmRepository())
    }
    
    private func makeFetchChatMessageListUseCase() -> FetchChatMessageListUseCase {
        DefaultRealmFetchChatMessageListUseCase(repo: makeChatMessageRealmRepository())
    }
    
    private func makeFetchRemoteChatMessagesUseCase() -> FetchRemoteChatMessagesUseCase {
        DefaultFetchRemoteChatMessagesUseCase(repo: makeChatRepository())
    }
    
    // MARK: Chat Room Bundle
    private func makeChatRoomListUseCases() -> ChatRoomListUseCases {
        ChatRoomListUseCases(
            fetchRemoteChatRoomList: makeChatRoomListUseCase(),
            saveRealmLastMessage: makeSaveLatestChatRoomUseCase(),
            fetchRealmChatRoomList: makeFetchChatRoomListUseCase()
        )
    }
    
    
    private func makeChatRoomListUseCase() -> ChatRemoteRoomListUseCase {
        DefaultChatRoomListUseCase(repo: makeChatRepository())
    }

    private func makeSaveLatestChatRoomUseCase() -> SaveRealmLatestChatRoomUseCase {
        DefaultSaveLatestChatRoomUseCase(repo: makChatRoomRealmRepository())
    }

    private func makeFetchChatRoomListUseCase() -> FetchRealmChatRoomListUseCase {
        DefaultFetchChatRoomListUseCase(repo: makChatRoomRealmRepository())
    }

    

}


// MARK: Data
extension ChatDIContainer {
    

    private func makeChatMessageRealmRepository() -> DefaultChatMessageRealmRepository {
        DefaultChatMessageRealmRepository()
    }
    
    
    private func makChatRoomRealmRepository() -> DefaultChatRoomRealmRepository {
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
            opponentNick: opponentNick,
            chatUseCases: makeChatListUseCases(),
            profileSearchUseCase: commonDIContainer.makeProfileSearchUseCase(),
            imageLoadUseCases: commonDIContainer.makeImageLoadUseCase()
        )
    }
    
    
    func makeChatListViewModel() -> ChatListViewModel {
        ChatListViewModel(
            chatRoomUseCases: makeChatRoomListUseCases(),
            profileSearchUseCase: commonDIContainer.makeProfileSearchUseCase(),
            imageLoadUseCases: commonDIContainer.makeImageLoadUseCase()
        )
    }
   
    
}

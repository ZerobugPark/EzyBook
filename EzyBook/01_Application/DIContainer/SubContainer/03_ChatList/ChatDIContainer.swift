//
//  ChatDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 7/25/25.
//

import Foundation

protocol ChatFactory {
    
    func makeChatListViewModel() -> ChatListViewModel
    func makeChatRoomViewModel(roomID: String, opponentNick: String) -> ChatRoomViewModel
    func makePDFViewModel(path: String) -> PDFViewModel
}



final class ChatDIContainer {
    
    
    private let networkService: DefaultNetworkService
    private let commonDIContainer: CommonDIContainer
    private let socketService: SocketServicePool
    
    init(networkService: DefaultNetworkService, commonDIContainer: CommonDIContainer, storage: TokenStorage) {
        self.networkService = networkService
        self.commonDIContainer = commonDIContainer
        self.socketService = SocketServicePool(keyChain: storage)
    }
    
    
    func makeFactory() -> ChatFactory { Impl(container: self) }
    
    
    private final class Impl: ChatFactory {
  
        private let container: ChatDIContainer
        init(container: ChatDIContainer) { self.container = container }

        
        func makeChatRoomViewModel(roomID: String, opponentNick: String) -> ChatRoomViewModel {
            
            let socketService: SocketService = container.socketService.service(for: roomID)
            
            return ChatRoomViewModel(
                socketService: socketService,
                roomID: roomID,
                chatUseCases: container.makeChatListUseCases(),
                opponentNick: opponentNick
            )
        }
        
        
        func makeChatListViewModel() -> ChatListViewModel {
            ChatListViewModel(
                fetchChatListUseCase: container.makeFetchRealmChatRoomListUseCase(),
                chatListUseCase: container.makeChatRemoteRoomListUseCase(),
                unReadCountUseCase: container.commonDIContainer.makeGetUnReadChatCount()
            )
        }
        
        func makePDFViewModel(path: String) -> PDFViewModel {
            PDFViewModel(
                fileLoad: container.makeFileLoadUseCase(),
                path: path
            )
        }
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
            fetchRemoteMessage: makeFetchRemoteChatMessagesUseCase(),
            uploadImage: makeChatImageUploadUseCase(),
            uploadFile: makeChatFileUploadUseCase(),
            resetUnReadCount: commonDIContainer.makeResetUnReadCount()
        )
    }
    

    // MARK: Server
    private func makeSendMessageUseCase() -> SendMessageUseCase {
        DefaultChatSendMessageUseCase(repo: makeChatRepository())
    }
    
    private func makeSaveChatMessageUseCase() -> SaveChatMessageUseCase {
        DefaultRealmSaveChatMessageUseCase(repo:  makeChatMessageRealmRepository())
    }
    
    /// 채팅방 이미지 업로드
    private func makeChatImageUploadUseCase() -> ChatImageUploadUseCase {
        DefaultChatImageUploadUseCase(repo: makeChatRepository())
    }
    
    /// 채팅방 파일 업로드
    private func makeChatFileUploadUseCase() -> ChatFileUploadUseCase {
        DefaultChatFileUploadUseCase(repo: makeChatRepository())
    }
    
    /// 채팅방 파일 로드
    private func makeFileLoadUseCase() -> DefaultFileLoadUseCase {
        DefaultFileLoadUseCase(repo: makeChatRepository())
    }
    
    ///  채팅 목록 조회
    private func makeFetchRealmChatRoomListUseCase() -> FetchRealmChatRoomListUseCase {
        DefaultFetchRealmChatRoomListUseCase(repo: makeChatMessageRealmRepository())
    }

    /// 채팅방 목록 조회
    private func makeChatRemoteRoomListUseCase() -> ChatRemoteRoomListUseCase {
        DefaultChatRemoteRoomListUseCase(repo: makeChatRepository())
    }
    
    /// 채팅방 내 채팅 내역 불러오기
    private func makeFetchRemoteChatMessagesUseCase() -> FetchRemoteChatMessagesUseCase {
        DefaultFetchRemoteChatMessagesUseCase(repo: makeChatRepository())
    }
    
    // MARK: Local DB
    /// 메시지 내역 조회
    private func makeFetchChatMessageListUseCase() -> FetchChatMessageListUseCase {
        DefaultRealmFetchChatMessageListUseCase(repo: makeChatMessageRealmRepository())
    }
    
    
    /// 가장 최근 메시지 조회
    private func makeFetchLatestChatMessageUseCase() -> FetchLatestChatMessageUseCase {
        DefaultRealmFetchLatestChatMessageUseCase(repo:  makeChatMessageRealmRepository())
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




//
//  ChatRoomImplementation.swift
//  EzyBook
//
//  Created by youngkyun park on 7/17/25.
//

import Foundation

// MARK: Remote
// MARK: 메시지 전송 Clinet to Server
final class DefaultChatSendMessageUseCase: SendMessageUseCase {
    
    private let repo: any ChatSendMessageRepository
    
    init(repo: any ChatSendMessageRepository) {
        self.repo = repo
    }
    
    func execute(roomId: String, content: String, files: [String]?) async throws -> ChatEntity {
    
        do {
            return try await repo.requestSendMessage(roomId, content, files)
        } catch  {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
    }

}

final class DefaultFetchRemoteChatMessagesUseCase: FetchRemoteChatMessagesUseCase {
    
    private let repo: ChatListRepository
    
    init(repo: ChatListRepository) {
        self.repo = repo
    }
    
    func execute(id: String, next: String?) async throws -> [ChatEntity] {
        
        let dto: ChatListRequestDTO
        if let next {
            dto = ChatListRequestDTO(next: next)
        } else {
            dto = ChatListRequestDTO(next: nil)
        }
        
        let router = ChatRequest.Get.lookUpChatList(id: id, dto: dto)
        
        do {
            return try await
            self.repo.requestChatlist(router)
            
        } catch  {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
            
        }
    }
}



// MARK: Local
// MARK: 메시지 내역 (Realm)
final class DefaultRealmFetchChatMessageListUseCase: FetchChatMessageListUseCase {
  
    private let repo: any ChatMessageRealmRepository
    
    init(repo: any ChatMessageRealmRepository) {
        self.repo = repo
    }
    
    func excute(roomID: String, before: String?, limit: Int, userID: String) -> [ChatMessageEntity] {
        let data = repo.fetchMessageList(roomID: roomID, before: before, limit: limit, userID: userID)

        return data
    }


}

// MARK: 가장 최근 메시지 내역 (Realm)
final class DefaultRealmFetchLatestChatMessageUseCase: FetchLatestChatMessageUseCase {
    
    private let repo: any ChatMessageRealmRepository
    
    init(repo: any ChatMessageRealmRepository) {
        self.repo = repo
    }
    
    func execute(roodID: String, userID: String) -> ChatMessageEntity? {
      
        let data = repo.fetchLatestMessages(roomID: roodID, userID: userID)
        return data
    }
    

}

// MARK: 메시지 저장 (Realm)

final class DefaultRealmSaveChatMessageUseCase: SaveChatMessageUseCase {

    
    private let repo: any ChatMessageRealmRepository
    
    init(repo: any ChatMessageRealmRepository) {
        self.repo = repo
    }
    
    
    func execute(chatList: [ChatMessageEntity]) {
        repo.save(chatList: chatList)
    }


}

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
    
 

}

extension DefaultChatSendMessageUseCase {
    func execute(roomId: String, content: String, files: [String]?) async throws -> ChatEntity {
        try await repo.requestSendMessage(roomId, content, files)
    }
}

    
    
/// 채팅 리스트
final class DefaultFetchRemoteChatMessagesUseCase: FetchRemoteChatMessagesUseCase {
    
    private let repo: ChatListRepository
    
    init(repo: ChatListRepository) {
        self.repo = repo
    }
    
}
    
extension DefaultFetchRemoteChatMessagesUseCase {
    func execute(id: String, next: String?) async throws -> [ChatEntity] {
        
        try await repo.requestChatlist(id, next)

    }
}



// MARK: Local
// MARK: 메시지 내역 (Realm)
final class DefaultRealmFetchChatMessageListUseCase: FetchChatMessageListUseCase {
  
    private let repo: any ChatMessageRealmRepository
    
    init(repo: any ChatMessageRealmRepository) {
        self.repo = repo
    }

}

extension DefaultRealmFetchChatMessageListUseCase {
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


}
extension DefaultRealmFetchLatestChatMessageUseCase {
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
    

}
extension DefaultRealmSaveChatMessageUseCase {
    
    func execute(chatList: [ChatMessageEntity]) {
        repo.save(chatList: chatList)
    }
}

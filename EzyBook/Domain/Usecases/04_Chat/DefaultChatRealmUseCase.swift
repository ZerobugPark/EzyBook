//
//  DefaultChatRealmUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 7/6/25.
//

import Foundation

final class DefaultChatRealmUseCase {
    
    private let repo: any ChatMessageRealmRepository
    
    init(repo: any ChatMessageRealmRepository) {
        self.repo = repo
    }
    
    func executeSaveData(chatList: [ChatMessageEntity]) {
        
        repo.save(chatList: chatList)
    }
    
    func excutefetchLatestMessage(roodID: String, opponentID: String) -> ChatMessageEntity? {
        
        let data = repo.fetchLatestMessages(roomID: roodID, opponentID: opponentID)
        
        return data
        
    }
    
    func excuteFetchChatList(roomID: String, before: String?, limit: Int, opponentID: String) -> [ChatMessageEntity] {
        
        let data = repo.fetchMessageList(roomID: roomID, before: before, limit: limit, opponentID: opponentID)
        
        return data
    }
    

}


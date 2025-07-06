//
//  DefaultChatRealmUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 7/6/25.
//

import Foundation

final class DefaultChatRealmUseCase {
    
    private let repo: any DefaultChatDataRepository
    
    init(repo: any DefaultChatDataRepository) {
        self.repo = repo
    }
    
    func executeSaveData(chatList: [ChatEntity]) {
        
        let data = chatList.map {
            
            ChatMessageEntity(
                chatID: $0.chatId,
                content: $0.content,
                createdAt: $0.createdAt,
                files: $0.files,
                roomID: $0.roomId,
                sender: ChatMessageEntity.Sender(
                    userID: $0.sender.userID,
                    nick: $0.sender.nick
                )
            )
            
        }
        print(Thread.isMainThread)
        repo.save(chatList: data)
    }
}


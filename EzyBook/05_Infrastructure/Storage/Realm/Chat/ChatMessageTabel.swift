//
//  ChatMessageTabel.swift
//  EzyBook
//
//  Created by youngkyun park on 7/1/25.
//

import Foundation
import RealmSwift

final class ChatMessageTable: Object {
    @Persisted(primaryKey: true) var chatID: String
    @Persisted var roomID: String
    @Persisted var content: String
    @Persisted var createdAt: String
    @Persisted var _files: List<String>
    @Persisted var senderID: String
    @Persisted var senderNick: String
    
    var files: [String] {
           get { return Array(_files) }
           set {
               _files.removeAll()
               _files.append(objectsIn: newValue)
           }
    }
    
    convenience init(chatID: String, roomID: String, content: String, createdAt: String, files: [String], senderID: String, senderNick: String) {
        self.init()
        self.chatID = chatID
        self.roomID = roomID
        self.content = content
        self.createdAt = createdAt
        self.files = files
        self.senderID = senderID
        self.senderNick = senderNick
    }
}


extension ChatMessageTable {
    static func from(entity: ChatMessageEntity) -> ChatMessageTable {
        ChatMessageTable(
            chatID: entity.chatID,
            roomID: entity.roomID,
            content: entity.content,
            createdAt: entity.createdAt,
            files: entity.files,
            senderID: entity.sender.userID,
            senderNick: entity.sender.nick
        )
    }
}

//
//  ChatMessageTabel.swift
//  EzyBook
//
//  Created by youngkyun park on 7/1/25.
//

import Foundation
import RealmSwift

final class ChatMessageObject: Object {
    @Persisted(primaryKey: true) var chatID: String
    @Persisted var roomID: String  // 🔗 ChatRoomObject와 연결
    @Persisted var content: String
    @Persisted var createdAt: String
    @Persisted var files: List<String>
    @Persisted var senderID: String
    @Persisted var senderNick: String
    
    convenience init(chatID: String, roomID: String, content: String, createdAt: String, files: [String], senderID: String, senderNick: String) {
        self.init()
        self.chatID = chatID
        self.roomID = roomID
        self.content = content
        self.createdAt = createdAt
        self.files.append(objectsIn: files)
        self.senderID = senderID
        self.senderNick = senderNick
    }
}


extension ChatMessageObject {
    static func from(entity: ChatMessageEntity) -> ChatMessageObject {
        ChatMessageObject(
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

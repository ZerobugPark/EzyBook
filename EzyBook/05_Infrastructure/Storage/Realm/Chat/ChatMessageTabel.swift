//
//  ChatMessageTabel.swift
//  EzyBook
//
//  Created by youngkyun park on 7/1/25.
//

import Foundation
import RealmSwift

final class ChatRoomTable: Object {
    @Persisted(primaryKey: true) var roomID: String
    @Persisted var opponentUserID: String
    @Persisted var lastChatID: String
    @Persisted var lastMessage: String
    @Persisted var lastMessageTime: Date
    @Persisted var lastMessageSenderID: String
    @Persisted var _files: List<String>
    @Persisted var unreadCount: Int
    
    
    @Persisted var _messages: List<ChatMessageTable>
    
    var messages: [ChatMessageTable] {
        return Array(_messages)
    }
    
    var files: [String] {
        get { return Array(_files) }
        set {
            _files.removeAll()
            _files.append(objectsIn: newValue)
        }
    }
    
    convenience init(
        roomID: String,
        opponentUserID: String,
        lastChatID: String,
        lastMessage: String,
        lastMessageTime: Date,
        lastMessageSenderID: String,
        unreadCount: Int,
        files: [String],
        messages: [ChatMessageTable]
    ) {
        self.init()
        self.roomID = roomID
        self.opponentUserID = opponentUserID
        self.lastChatID = lastChatID
        self.lastMessage = lastMessage
        self.lastMessageTime = lastMessageTime
        self.lastMessageSenderID = lastMessageSenderID
        self.unreadCount = unreadCount
        self.files = files
        self._messages.append(objectsIn: messages)
    }
}




final class UserInfoTable: Object {
    @Persisted(primaryKey: true) var userID: String
    @Persisted var nick: String
    @Persisted var profileImageURL: String?
    
    
    convenience init(userID: String, nick: String, profileImageURL: String? = nil) {
        self.init()
        self.userID = userID
        self.nick = nick
        self.profileImageURL = profileImageURL

    }
}


final class ChatMessageTable: Object {
    @Persisted(primaryKey: true) var chatID: String
    @Persisted var content: String
    @Persisted var createdAt: Date
    @Persisted var _files: List<String>
    @Persisted var senderID: String

    var files: [String] {
        get { return Array(_files) }
        set {
            _files.removeAll()
            _files.append(objectsIn: newValue)
        }
    }

    convenience init(chatID: String, content: String, createdAt: Date, files: [String], senderID: String) {
        self.init()
        self.chatID = chatID
        self.content = content
        self.createdAt = createdAt
        self.files = files
        self.senderID = senderID
    }
}

extension ChatMessageTable {
    static func from(entity: ChatEntity) -> ChatMessageTable {
        ChatMessageTable(
            chatID: entity.chatID,
            content: entity.content,
            createdAt: entity.createdAt.toDate(),
            files: entity.files,
            senderID: entity.sender.userID
        )
    }

}

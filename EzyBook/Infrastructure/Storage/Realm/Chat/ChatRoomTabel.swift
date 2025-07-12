//
//  ChatRoomTabel.swift
//  EzyBook
//
//  Created by youngkyun park on 7/1/25.
//

import Foundation
import RealmSwift


/// 오프라인시 대비
final class ChatRoomTabel: Object {
    @Persisted(primaryKey: true) var roomID: String
    @Persisted var createdAt: String
    @Persisted var updatedAt: String?
    
    // 상대방 정보
    @Persisted var opponentID: String
    @Persisted var opponentNick: String

    // 마지막 메시지 정보
    @Persisted var lastMessageID: String
    @Persisted var lastMessageContent: String
    @Persisted var lastMessageCreatedAt: String
    @Persisted var lastMessageSenderID: String
    @Persisted var lastMessageFiles: List<String>
    
    convenience init (roomID: String, createdAt: String, updatedAt: String? = nil, opponentID: String, opponentNick: String, lastMessageID: String, lastMessageContent: String, lastMessageCreatedAt: String, lastMessageSenderID: String, lastMessageFiles: List<String>) {
        self.init()
        self.roomID = roomID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.opponentID = opponentID
        self.opponentNick = opponentNick
        self.lastMessageID = lastMessageID
        self.lastMessageContent = lastMessageContent
        self.lastMessageCreatedAt = lastMessageCreatedAt
        self.lastMessageSenderID = lastMessageSenderID
        self.lastMessageFiles = lastMessageFiles
    }
    
}


extension ChatRoomTabel {
    static func from(entity: ChatRoomEntity) -> ChatRoomTabel {
        
        let fileList = List<String>()
        fileList.append(objectsIn: entity.lastChat?.files ?? [])
        
        return ChatRoomTabel(
            roomID: entity.roomId,
            createdAt: entity.createdAt,
            opponentID: entity.participants[0].userID,
            opponentNick: entity.participants[0].nick,
            lastMessageID: entity.lastChat?.chatId ?? "" ,
            lastMessageContent: entity.lastChat?.content ?? "",
            lastMessageCreatedAt: entity.lastChat?.createdAt ?? "",
            lastMessageSenderID: entity.lastChat?.chatId ?? "",
            lastMessageFiles: fileList
        )
    }
}

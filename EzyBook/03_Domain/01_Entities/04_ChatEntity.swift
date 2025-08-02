//
//  04_ChatEntity.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import SwiftUI

struct ChatRoomEntity: Identifiable {
    let id = UUID()
    let roomID: String
    let createdAt: String
    let updatedAt: String?
    let participants: [UserInfoEntity]
    let lastChat: ChatEntity?
    var opponentImage: UIImage? = nil
    var opponentIndex: Int? = nil
    
    init(dto: ChatRoomResponseDTO) {
        self.roomID = dto.roomId
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
        self.participants = dto.participants.map {
            UserInfoEntity(dto: $0)
        }
        self.lastChat = dto.lastChat.map { ChatEntity(dto: $0) }
    }
    
    init(
        roomId: String,
        createdAt: String,
        updatedAt: String?,
        participants: [UserInfoEntity],
        lastChat: ChatEntity?,
        opponentImage: UIImage? = nil
    ) {
        self.roomID = roomId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.participants = participants
        self.lastChat = lastChat
        self.opponentImage = opponentImage
    }
}


struct ChatEntity {
    let chatID: String
    let roomID: String
    let content: String
    let createdAt: String
    let updatedAt: String
    let sender: UserInfoEntity
    let files: [String]
    
    init(dto: ChatResponseDTO) {
        self.chatID = dto.chatId
        self.roomID = dto.roomId
        self.content = dto.content
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
        self.sender = UserInfoEntity(dto: dto.sender)
        self.files = dto.files
    }
    
    init(chatId: String, roomId: String, content: String, createdAt: String, updatedAt: String, sender: UserInfoEntity, files: [String]) {
        self.chatID = chatId
        self.roomID = roomId
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sender = sender
        self.files = files
    }
}


struct ChatMessageEntity {
    let chatID: String
    let content: String
    let createdAt: String
    let files: [String]
    let roomID: String
    let sender: Sender
    var isMine: Bool
    
    struct Sender {
        let userID: String
        let nick: String
    }
    
    
    init(chatID: String, content: String, createdAt: String, files: [String], roomID: String, sender: Sender, isMine: Bool) {
        self.chatID = chatID
        self.content = content
        self.createdAt = createdAt
        self.files = files
        self.roomID = roomID
        self.sender = sender
        self.isMine = isMine
    }
    
    
    init(entity: ChatEntity) {
        self.chatID = entity.chatID
        self.content = entity.content
        self.createdAt = entity.createdAt
        self.files = entity.files
        self.roomID = entity.roomID
        self.sender = Sender(userID: entity.sender.userID, nick: entity.sender.nick)
        self.isMine = false
    }
    
    static func from(dict: [String : Any]) -> ChatMessageEntity? {
         guard
             let chatID = dict["chat_id"] as? String,
             let content = dict["content"] as? String,
             let roomID = dict["room_id"] as? String,
             let createdAt = dict["createdAt"] as? String,
             let senderDict = dict["sender"] as? [String: Any],
             let userID = senderDict["user_id"] as? String,
             let nick = senderDict["nick"] as? String
         else {
             return nil
         }

         let files = dict["files"] as? [String] ?? []

         return ChatMessageEntity(
             chatID: chatID,
             content: content,
             createdAt: createdAt,
             files: files,
             roomID: roomID,
             sender: Sender(userID: userID, nick: nick),
             isMine: false
         )
     }
}


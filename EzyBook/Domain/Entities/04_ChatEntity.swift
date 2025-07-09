//
//  04_ChatEntity.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import Foundation

struct ChatRoomEntity {
    let roomId: String
    let createdAt: String
    let updatedAt: String?
    let participants: [UserInfoResponseEntity]
    let lastChat: ChatEntity?
    
    init(dto: ChatRoomResponseDTO) {
        self.roomId = dto.roomId
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
        self.participants = dto.participants.map {
            UserInfoResponseEntity(dto: $0)
        }
        self.lastChat = dto.lastChat != nil ? ChatEntity(dto: dto.lastChat!) : nil
    }
    
}


struct ChatEntity {
    let chatId: String
    let roomId: String
    let content: String
    let createdAt: String
    let updatedAt: String
    let sender: UserInfoResponseEntity
    let files: [String]
    
    init(dto: ChatResponseDTO) {
        self.chatId = dto.chatId
        self.roomId = dto.roomId
        self.content = dto.content
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
        self.sender = UserInfoResponseEntity(dto: dto.sender)
        self.files = dto.files
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



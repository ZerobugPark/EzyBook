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
    
    
    init(dto: ChatRoomResponseDTO) {
        self.roomID = dto.roomId
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
        self.participants = dto.participants.map {
            UserInfoEntity(dto: $0)
        }
        self.lastChat = dto.lastChat.map { ChatEntity(dto: $0) }
    }
    
}


struct ChatEntity {
    let chatID: String
    let roomID: String
    let content: String
    let createdAt: String
    let updatedAt: String
    let sender: UserInfoEntity
    var files: [String]
    
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

extension ChatEntity {
    
    static func from(dict: [String : Any]) -> ChatEntity? {
         guard
             let chatID = dict["chat_id"] as? String,
             let content = dict["content"] as? String,
             let roomID = dict["room_id"] as? String,
             let createdAt = dict["createdAt"] as? String,
             let senderDict = dict["sender"] as? [String: Any],
             let userID = senderDict["user_id"] as? String,
             let nick = senderDict["nick"] as? String,
             let profileImage = senderDict["profileImage"] as? String
         else {
             return nil
         }

         let files = dict["files"] as? [String] ?? []

        return ChatEntity(
            chatId: chatID,
            roomId: roomID,
            content: content,
            createdAt: createdAt,
            updatedAt: userID,
            sender: UserInfoEntity(
                dto: UserInfoResponseDTO(
                    userID: userID,
                    nick: nick,
                    profileImage: profileImage,
                    introduction: ""
                )
            ),
            files: files
        )
     }
}


struct ChatMessageEntity {
    let chatID: String
    let content: String
    let createdAt: Date
    let files: [String]
    let opponentInfo: OpponentSummary
    
    var isMine: Bool

    var formatTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR") // 한국어 오전/오후
        formatter.dateFormat = "a hh:mm" // "오전 10:23" / "오후 03:45"
        return formatter.string(from: self.createdAt)
        
    }
}


struct LastMessageSummary: Identifiable, Equatable {
    
    var id: String { roomID }
    let roomID: String
    let content: String
    let updateAt: Date
    let unreadCount: Int
    let opponentInfo: OpponentSummary
    let files: [String]
    
    var formattedDate: String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(updateAt) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            return timeFormatter.string(from: updateAt)
        }

        if calendar.isDateInYesterday(updateAt) {
            return "어제"
        }

        let inputYear = calendar.component(.year, from: updateAt)
        let currentYear = calendar.component(.year, from: now)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = (inputYear == currentYear) ? "MM.dd" : "yyyy.MM.dd"

        return dateFormatter.string(from: updateAt)
    }
    
}

struct OpponentSummary: Equatable {
    let userID: String
    let nick: String
    let profileImageURL: String?
}


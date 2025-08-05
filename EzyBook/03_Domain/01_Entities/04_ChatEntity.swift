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
    let createdAt: Date
    let files: [String]
    let roomID: String
    
    var isMine: Bool
    
    struct Sender {
        let userID: String
        let nick: String
        let profilePath: String?
    }
    
    
    init(chatID: String, content: String, createdAt: Date, files: [String], roomID: String, sender: Sender, isMine: Bool) {
        self.chatID = chatID
        self.content = content
        self.createdAt = createdAt
        self.files = files
        self.roomID = roomID
        self.isMine = isMine
    }
    
    
    init(entity: ChatEntity) {
        self.chatID = entity.chatID
        self.content = entity.content
        self.createdAt = entity.createdAt.toDate()
        self.files = entity.files
        self.roomID = entity.roomID
        self.isMine = false
    }
    
//    static func from(dict: [String : Any]) -> ChatMessageEntity? {
//         guard
//             let chatID = dict["chat_id"] as? String,
//             let content = dict["content"] as? String,
//             let roomID = dict["room_id"] as? String,
//             let createdAt = dict["createdAt"] as? String,
//             let senderDict = dict["sender"] as? [String: Any],
//             let userID = senderDict["user_id"] as? String,
//             let nick = senderDict["nick"] as? String
//         else {
//             return nil
//         }
//
//         let files = dict["files"] as? [String] ?? []
//
//         return ChatMessageEntity(
//             chatID: chatID,
//             content: content,
//             createdAt: createdAt.toDate(),
//             files: files,
//             roomID: roomID,
//             sender: Sender(userID: userID, nick: nick, profilePath: nil),
//             isMine: false
//         )
//     }
}


struct LastMessageSummary: Identifiable {
    let id = UUID()
    let content: String
    let updateAt: Date
    let unreadCount: Int
    let opponentInfo: OpponentSummary
    
    
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

struct OpponentSummary {
    let userID: String
    let nick: String
    let profileImageURL: String?
}

extension ChatRoomEntity {
    func toLastMessageSummary(myID: String) -> LastMessageSummary {
        let opponent = participants.first { $0.userID != myID }
        let opponentSummary = OpponentSummary(
            userID: opponent?.userID ?? "",
            nick: opponent?.nick ?? "알 수 없음",
            profileImageURL: opponent?.profileImage
        )

        return LastMessageSummary(
            content: lastChat?.content ?? "",
            updateAt: lastChat?.updatedAt.toDate() ?? Date(),
            unreadCount: 0,
            opponentInfo: opponentSummary
        )
    }
}

//
//  04_ChatResponseMapper.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import Foundation


extension ChatRoomResponseDTO {
    func toEntity() -> ChatRoomEntity {
        ChatRoomEntity(dto: self)
    }
}

extension ChatListResponseDTO {
    func toEntity() -> [ChatEntity] {
        self.data.map { ChatEntity(dto: $0) }
    }
}


extension ChatResponseDTO {
    func toEntity() -> ChatEntity {
        ChatEntity(dto: self)
    }
}

extension ChatMessageObject {
    func toEntity() -> ChatMessageEntity {
        ChatMessageEntity(
            chatID: self.chatID,
            content: self.content,
            createdAt: self.createdAt,
            files: self.files,
            roomID: self.roomID,
            sender: ChatMessageEntity
                .Sender(
                    userID: self.senderID,
                    nick: self.senderNick
                )
        )
    }
}

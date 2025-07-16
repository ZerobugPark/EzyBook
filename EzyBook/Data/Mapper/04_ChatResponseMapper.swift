//
//  04_ChatResponseMapper.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import Foundation

extension ChatRoomListResponseDTO {
    func toEntity() -> [ChatRoomEntity] {
        self.data.map { ChatRoomEntity(dto: $0) }
    }
}

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

extension ChatMessageTable {
    func toEntity(userID: String? = nil) -> ChatMessageEntity {

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
                ),
            isMine: userID == self.senderID
        )
    }

}

extension ChatRoomTabel {
    
    func toEntity() -> ChatRoomEntity {
        return ChatRoomEntity(
            roomId: self.roomID,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            participants: [UserInfoResponseEntity(
                userID: self.opponentID,
                nick: self.opponentNick
            )],
            lastChat: ChatEntity(
                chatId: self.lastMessageSenderID,
                roomId: self.roomID,
                content: self.lastMessageContent,
                createdAt: self.createdAt,
                updatedAt: self.createdAt,
                sender: UserInfoResponseEntity(
                    userID: self.opponentID,
                    nick: self.opponentNick
                ),
                files: Array(self.lastMessageFiles)
            )
        )
    }
    
}



extension ChatEntity {
    func toEnity() -> ChatMessageEntity {
        return ChatMessageEntity(entity: self)
    }
    
    func toEnity(userID: String) -> ChatMessageEntity {
        ChatMessageEntity(
            chatID: self.chatID,
            content: self.content,
            createdAt: self.createdAt,
            files: self.files,
            roomID: self.roomID,
            sender: ChatMessageEntity
                .Sender(
                    userID: self.sender.userID,
                    nick: self.sender.nick
                ),
            isMine: userID == self.sender.userID
        )

    }
}

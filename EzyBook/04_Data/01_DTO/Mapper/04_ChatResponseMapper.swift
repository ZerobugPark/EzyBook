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

extension ChatEntity {
    
    func toEntity(myID: String) -> ChatMessageEntity {
        
        ChatMessageEntity(
            chatID: self.chatID,
            content: self.content,
            createdAt: self.createdAt.toDate(),
            files: self.files,
            opponentInfo: OpponentSummary(
                userID: self.sender.userID,
                nick: self.sender.nick,
                profileImageURL: self.sender.profileImage
            ),
            isMine: self.sender.userID == myID
        )
    }
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
            roomID: lastChat?.roomID ?? "",
            content: lastChat?.content ?? "",
            updateAt: lastChat?.updatedAt.toDate() ?? Date(),
            unreadCount: 0,
            opponentInfo: opponentSummary,
            files: lastChat?.files ?? []
        )
    }
}

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

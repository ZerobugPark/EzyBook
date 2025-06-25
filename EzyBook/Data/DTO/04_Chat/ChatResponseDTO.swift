//
//  ChatResponseDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 6/25/25.
//

import Foundation


struct ChatRoomListResponseDTO: Decodable {
    let data: [ChatRoomResponseDTO]
}

struct ChatRoomResponseDTO: Decodable {
    let roomId: String
    let createdAt: String
    let updatedAt: String
    let participants: [UserInfoResponseDTO]
    let lastChat: ChatResponseDTO?

    private enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case participants
        case lastChat = "last_chat"
    }
}


struct ChatListResponseDTO: Decodable {
    let data: [ChatResponseDTO]
    
}

struct ChatResponseDTO: Decodable {
    let chatId: String
    let roomId: String
    let content: String
    let createdAt: String
    let updatedAt: String
    let sender: UserInfoResponseDTO
    let files: [String]

    private enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case roomId = "room_id"
        case content
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case sender
        case files
    }
}

struct ChatFileResponseDTO: Decodable {
    let files: [String]
}

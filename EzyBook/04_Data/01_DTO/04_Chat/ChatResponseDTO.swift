//
//  ChatResponseDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 6/25/25.
//

import Foundation


struct ChatRoomListResponseDTO: Decodable, EntityConvertible {
    let data: [ChatRoomResponseDTO]
}

struct ChatRoomResponseDTO: Decodable, EntityConvertible {
    let roomId: String
    let createdAt: String
    let updatedAt: String
    let participants: [UserInfoResponseDTO]
    let lastChat: ChatResponseDTO?

    private enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case createdAt
        case updatedAt
        case participants
        case lastChat
    }
}


struct ChatListResponseDTO: Decodable, EntityConvertible {
    let data: [ChatResponseDTO]
    
}

struct ChatResponseDTO: Decodable, EntityConvertible {
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
        case createdAt
        case updatedAt
        case sender
        case files
    }
}

struct ChatFileResponseDTO: Decodable, EntityConvertible {
    let files: [String]
}

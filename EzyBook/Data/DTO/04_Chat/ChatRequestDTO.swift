//
//  ChatRequestDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 6/25/25.
//

import Foundation

struct ChatRoomLookUpRequestDTO: Encodable {
    let opponentID: String
    
    enum CodingKeys: String, CodingKey {
        case opponentID = "opponent_id"
    }
}

struct SendChatRequestDTO: Encodable {
    let content: String
    let files: [String]?

}

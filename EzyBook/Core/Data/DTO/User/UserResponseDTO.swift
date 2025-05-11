//
//  UserResponseDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import Foundation

/// 프로필 조회
struct ProfileResponseDTO {
    let userID: String
    let email: String
    let nick: String
    let profileImage: String?
    let phoneNum: String
    let introduction: String
    
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email
        case nick
        case profileImage
        case phoneNum
        case introduction
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        userID = try container.decode(String.self, forKey: .userID)
        email = try container.decode(String.self, forKey: .email)
        nick = try container.decode(String.self, forKey: .nick)
        profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
        phoneNum = try container.decodeIfPresent(String.self, forKey: .phoneNum) ?? ""
        introduction = try container.decodeIfPresent(String.self, forKey: .introduction) ?? ""

    }
    
}

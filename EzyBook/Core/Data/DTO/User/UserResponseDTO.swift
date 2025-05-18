//
//  UserResponseDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import Foundation

// MARK: Get
/// 프로필 조회
struct ProfileCheckResponseDTO: Decodable, EntityConvertible {
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

// MARK: Post(Response)
/// 이메일 유효성 검사
struct EmailValidationResponseDTO: Decodable, EntityConvertible {
    let message: String
}

/// 회원가입
struct JoinResponseDTO: Decodable, EntityConvertible {
    let userID: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email
        case nick
        case accessToken
        case refreshToken
    }
    
}

/// 로그인 (이메일, 카카오, 애플 공통)
struct LoginResponseDTO: Decodable, EntityConvertible {
    let userID: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email
        case nick
        case accessToken
        case refreshToken
    }
    
}


// MARK: UserReponseDTO Extension

extension ProfileCheckResponseDTO {
    
    func toEntity() -> ProfileCheckEntity {
        return ProfileCheckEntity(
            userID: self.userID,
            email: self.email,
            nick: self.nick,
            profileImage: self.profileImage,
            phoneNum: self.phoneNum,
            introduction: self.introduction
        )
    }
}

extension EmailValidationResponseDTO {
    
    func toEntity() -> EmailValidationEntity {
        return EmailValidationEntity(message: self.message)
    }
}


extension JoinResponseDTO {
    
    func toEntity() -> JoinEntity {
        return JoinEntity(
            userID: self.userID,
            email: self.email,
            nick: self.nick,
            accessToken: self.accessToken,
            refreshToken: self.refreshToken
        )
    }
}


extension LoginResponseDTO {
    
    func toEntity() -> LoginEntity {
        return LoginEntity(
            userID: self.userID,
            email: self.email,
            nick: self.nick,
            accessToken: self.accessToken,
            refreshToken: self.accessToken
        )
    }
}


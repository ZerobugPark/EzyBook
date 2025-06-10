//
//  UserResponseDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import Foundation

// MARK: Get

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

/// 프로필 조회 및 수정 응답 값
struct ProfileLookUpResponseDTO: Decodable, EntityConvertible {
    let userID: String
    let email: String
    let nick: String
    let profileImage: String?
    let phoneNum: String?
    let introduction: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email
        case nick
        case profileImage
        case phoneNum
        case introduction
    }
    
}

/// 프로필 조회 및 수정 응답 값
struct UserInfoListResponseDTO: Decodable, EntityConvertible {
    let data: [UserInfoResponseDTO]
    
}

/// 프로필 조회 및 수정 응답 값 
struct UserInfoResponseDTO: Decodable {
    let userID: String
    let nick: String
    let profileImage: String?
    let introduction: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case nick
        case profileImage
        case introduction
    }
    
}

/// 프로필 리턴
struct ProfileImageUploadResponseDTO: Decodable, EntityConvertible {
    let profileImage: String
}

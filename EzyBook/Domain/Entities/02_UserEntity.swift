//
//  UserEntity.swift
//  EzyBook
//
//  Created by youngkyun park on 5/14/25.
//

import Foundation

struct EmailValidationEntity {
    let message: String
}


/// 회원가입
struct JoinEntity {
    let userID: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String
    
    init(dto: JoinResponseDTO) {
        self.userID = dto.userID
        self.email = dto.email
        self.nick = dto.nick
        self.accessToken = dto.accessToken
        self.refreshToken = dto.refreshToken
    }
    
}

/// 로그인 (이메일, 카카오, 애플 공통)
struct LoginEntity {
    let userID: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String
    
    init(dto: LoginResponseDTO) {
        self.userID = dto.userID
        self.email = dto.email
        self.nick = dto.nick
        self.accessToken = dto.accessToken
        self.refreshToken = dto.refreshToken
    }
    
}

/// 로그인 (이메일, 카카오, 애플 공통)
struct ProfileLookUpEntity {
    let userID: String
    let email: String
    let nick: String
    let profileImage: String
    let phoneNum: String
    let introduction: String
    
    init(dto: ProfileLookUpResponseDTO) {
        self.userID = dto.userID
        self.email = dto.email
        self.nick = dto.nick
        self.profileImage = dto.profileImage ?? ""
        self.phoneNum = dto.phoneNum ?? ""
        self.introduction = dto.introduction ?? ""
    }
    
    var hasProfileImage: Bool {
        profileImage.isEmpty
    }
    
}

/// 유저검색
struct UserInfoResponseEntity {
    let userID: String
    let nick: String
    let profileImage: String?
    let introduction: String?
    
    init(dto: UserInfoResponseDTO) {
        self.userID = dto.userID
        self.nick = dto.nick
        self.profileImage = dto.profileImage
        self.introduction = dto.introduction
    }
    
}

/// 유저검색
struct UserImageUploadEntity {

    let profileImage: String
   
    
    init(dto: ProfileImageUploadResponseDTO) {
        self.profileImage = dto.profileImage
    }
    
}




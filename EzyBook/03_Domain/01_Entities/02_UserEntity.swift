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

/// 유저정보 (공유인스턴스)
struct UserEntity: Codable {
    let userID: String
    let email: String
    let nick: String
    
    init(userID: String, email: String, nick: String) {
        self.userID = userID
        self.email = email
        self.nick = nick
    }
    
    init(dto: LoginEntity) {
        self.userID = dto.userID
        self.email = dto.email
        self.nick = dto.nick
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

extension ProfileLookUpEntity {
    static let skeleton = ProfileLookUpEntity(
        dto: ProfileLookUpResponseDTO(
            userID: "",
            email: "",
            nick: "",
            profileImage: nil,
            phoneNum: "",
            introduction: ""
        )
    )
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
    
    init(userID: String, nick: String, profileImage: String? = nil, introduction: String? = nil) {
        self.userID = userID
        self.nick = nick
        self.profileImage = profileImage
        self.introduction = introduction
    }
    
}

/// 유저검색
struct UserImageUploadEntity {

    let profileImage: String
   
    
    init(dto: ProfileImageUploadResponseDTO) {
        self.profileImage = dto.profileImage
    }
    
}




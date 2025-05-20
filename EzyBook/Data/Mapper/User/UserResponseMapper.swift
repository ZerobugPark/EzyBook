//
//  UserResponseMapper.swift
//  EzyBook
//
//  Created by youngkyun park on 5/20/25.
//

import Foundation

// MARK: UserRepons Mapper
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
            refreshToken: self.refreshToken
        )
    }
}


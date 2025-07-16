//
//  UserResponseMapper.swift
//  EzyBook
//
//  Created by youngkyun park on 5/20/25.
//

import Foundation

// MARK: UserRepons Mapper

extension EmailValidationResponseDTO {
    
    func toEntity() -> EmailValidationEntity {
        EmailValidationEntity(message: self.message)
    }
}


extension JoinResponseDTO {
    
    func toEntity() -> JoinEntity {
        JoinEntity.init(dto: self)
    }
}


extension LoginResponseDTO {
    
    func toEntity() -> LoginEntity {
        LoginEntity.init(dto: self)
    }
}

extension ProfileLookUpResponseDTO {
    
    func toEntity() -> ProfileLookUpEntity {
        ProfileLookUpEntity.init(dto: self)
    }
}

extension UserInfoListResponseDTO {
    
    func toEntity() -> [UserInfoResponseEntity] {
        data.map(UserInfoResponseEntity.init)
    }
}

extension ProfileImageUploadResponseDTO {
    func toEntity() -> UserImageUploadEntity {
        UserImageUploadEntity(dto: self)
    }
}


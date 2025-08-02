//
//  ProfileImpl.swift
//  EzyBook
//
//  Created by youngkyun park on 7/24/25.
//

import SwiftUI


// MARK: 프로필 조회
final class DefaultProfileLookUpUseCase: ProfileLookUpUseCase {
        
    let repo: ProfileLookupRepository
    
    init(repo: ProfileLookupRepository) {
        self.repo = repo
    }
    
}

extension DefaultProfileLookUpUseCase {
    func execute() async throws -> ProfileLookUpEntity {
        try await repo.requestProfileLookUp()
    }
}


// MARK: 유저 검색
final class DefaultProfileSearchUseCase: ProfileSearchUseCase {
        
    let repo: ProfileSearchRepository
    
    init(repo: ProfileSearchRepository) {
        self.repo = repo
    }

}

extension DefaultProfileSearchUseCase {
    
    func execute(nick: String) async throws -> [UserInfoEntity] {
        try await repo.requestSearchProfile(nick)
    }

}


// MARK: 프로필 이미지 업로드
final class DefaultProfileUploadImageUseCase: ProfileUploadImageUseCase {
    
    private let repo: ProfileImageUploadRepository
    
    init(repo: ProfileImageUploadRepository) {
        self.repo = repo
    }
}

extension DefaultProfileUploadImageUseCase {

    func execute(image: UIImage) async throws -> UserImageUploadEntity {
        try await repo.requestUploadImage(image)
    }
}



// MARK: 프로필 수정
final class DefaultProfileModifyUseCase: ProfileModifyUseCase {
        
    let repo: ProfileModifyRepository
    
    init(repo: ProfileModifyRepository) {
        self.repo = repo
    }

}

extension DefaultProfileModifyUseCase {
    
    func execute(nick: String?, profileImage: String?, phoneNum: String?, introduce: String?)  async throws -> ProfileLookUpEntity {
        try await repo.requestModifyProfile(nick, profileImage, phoneNum, introduce)
    }

}

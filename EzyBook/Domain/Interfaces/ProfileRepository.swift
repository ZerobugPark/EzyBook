//
//  ProfileRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import Foundation

protocol ProfileLookupRepository {
    func requestProfileLookUp(_ router: UserGetRequest) async throws -> ProfileLookUpEntity
}

protocol ProfileUploadRepository {
    func requestUploadImage(_ router: UserPostRequest) async throws -> UserImageUploadEntity
}

protocol ProfileModifyRepository {
    func requestModifyProfile(_ router: UserPostRequest) async throws -> ProfileLookUpEntity
}

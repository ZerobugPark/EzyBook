//
//  ProfileRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import Foundation

protocol ProfileLookupRepository {
    func requestProfileLookUp(_ router: UserRequest.Get) async throws -> ProfileLookUpEntity
}

protocol ProfileImageUploadRepository {
    func requestUploadImage(_ router: UserRequest.Multipart) async throws -> UserImageUploadEntity

}

protocol ProfileModifyRepository {
    func requestModifyProfile(_ router: UserRequest.Put) async throws -> ProfileLookUpEntity
}

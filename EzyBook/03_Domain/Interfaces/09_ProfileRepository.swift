//
//  ProfileRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import SwiftUI

protocol ProfileLookupRepository {
    func requestProfileLookUp() async throws -> ProfileLookUpEntity
}

protocol ProfileImageUploadRepository {
    func requestUploadImage(_ image: UIImage) async throws -> UserImageUploadEntity

}

protocol ProfileModifyRepository {
    func requestModifyProfile(_ nick: String?, _ profileImage: String?, _ phoneNum: String?, _ introduce: String?) async throws -> ProfileLookUpEntity
}

protocol ProfileSearchRepository {
    func requestSearchProfile(_ nick: String) async throws -> [UserInfoResponseEntity]
}

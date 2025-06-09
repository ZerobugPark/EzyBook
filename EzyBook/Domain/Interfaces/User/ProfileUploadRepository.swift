//
//  ProfileUploadRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import Foundation

protocol ProfileUploadRepository {
    func requestUploadImage(_ router: UserPostRequest) async throws -> UserImageUploadEntity
}

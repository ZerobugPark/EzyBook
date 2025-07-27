//
//  ProfileProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 7/24/25.
//

import SwiftUI

/// 프로필 조회
protocol ProfileLookUpUseCase {
    func execute() async throws -> ProfileLookUpEntity
}

/// 유저 검색
protocol ProfileSearchUseCase {
    func execute(nick: String) async throws -> [UserInfoResponseEntity]
}

/// 프로필 이미지 업로드
protocol ProfileUploadImageUseCase {
    func execute(image: UIImage) async throws -> UserImageUploadEntity
}

protocol ProfileModifyUseCase {
    func execute(nick: String?, profileImage: String?, phoneNum: String?, introduce: String?)  async throws -> ProfileLookUpEntity
}

//
//  UserRequestDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import Foundation


/// 이메일 유효성 검사
struct EmailValidationRequestDTO: Encodable {
    let email: String
}

/// 회원가입
struct JoinRequestDTO: Encodable {
    let email: String
    let password: String
    let nick: String
    let phoneNum: String?
    let introduction: String?
    let deviceToken: String?
}

/// 이메일 로그인
struct EmailLoginRequestDTO: Encodable {
    let email: String
    let password: String
    let deviceToken: String?
}

/// 카카오 로그인
struct KakaoLoginRequestDTO: Encodable {
    let oauthToken: String
    let deviceToken: String?
}

/// 애플  로그인
struct AppleLoginRequestDTO: Encodable {
    let idToken: String
    let deviceToken: String?
    let nick: String?
}

/// 프로필 수정
struct ProfileModifyRequestDTO: Encodable {
    let nick: String?
    let profileImage: String?
    let phoneNum: String?
    let introduction: String?
}

/// 프로필 이미지 등록
struct ProfileImageUploadRequestDTO: Encodable {
    let profileImage: String
}

/// 유저 검색
struct UserSearchRequestDTO: Encodable {
    let userName: String
}

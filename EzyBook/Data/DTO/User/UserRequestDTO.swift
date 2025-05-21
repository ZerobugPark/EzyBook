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


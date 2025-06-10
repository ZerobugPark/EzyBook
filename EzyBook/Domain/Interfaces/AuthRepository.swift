//
//  AuthRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import AuthenticationServices
import Foundation

protocol AppleLoginRepository {
    func requestAppleLogin(_ token: String, _ name: String?) async throws -> LoginEntity
}

protocol EmailLoginRepository {
    func requestEmailLogin(_ router: UserPostRequest) async throws -> LoginEntity
}

protocol KakaoLoginRepository {
    func requestKakaoLogin(_ token: String) async throws -> LoginEntity
}

protocol SignUpRepository {
    func verifyEmailAvailability(_ email: String) async throws
    func signUp(_ router: UserPostRequest) async throws
}

protocol SocialLoginService {
    func loginWithKakao() async throws -> String
    func loginWithApple(_ result: Result<ASAuthorization, any Error>) async throws -> (token: String, name: String?)
}

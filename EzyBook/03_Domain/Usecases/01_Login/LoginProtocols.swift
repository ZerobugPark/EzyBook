//
//  LoginProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 7/17/25.
//

import Foundation
import AuthenticationServices

protocol AppleLogin {
    func execute(_ result:  Result<ASAuthorization, any Error>) async throws -> UserEntity
}

protocol KakaoLogin {
    func execute() async throws -> UserEntity
}

protocol EmailLoginUseCase {
    func execute(email: String, password: String, deviceToken: String?) async throws -> UserEntity
}



// MARK: 회원가입
protocol SignUpUseCase {
    func execute(email: String, password: String, nick: String, phoneNum: String?, introduction: String?, deviceToken: String?) async throws -> Void 
}

protocol VerifyEmailUseCase {
    func execute(_ email: String) async throws -> Void
}

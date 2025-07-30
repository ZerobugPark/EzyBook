//
//  LoginImpl.swift
//  EzyBook
//
//  Created by youngkyun park on 7/27/25.
//

import AuthenticationServices
import Foundation

// MARK: 카카오 로그인
final class DefaultKakaoLoginUseCase: KakaoLoginUseCase {
    
    
    
    // 여기는 카카오 로그인과, apple 로그인이 필요
    private let kakoLoginService: SocialLoginService
    private let authRepository: KakaoLoginRepository
    private let tokenService: TokenWritable
    
    init(kakoLoginService: SocialLoginService, authRepository: KakaoLoginRepository, tokenService: TokenWritable) {
        self.kakoLoginService = kakoLoginService
        self.authRepository = authRepository
        self.tokenService = tokenService
    }
    
    
}
// MARK: Login
extension DefaultKakaoLoginUseCase {
    
    
    func execute() async throws -> UserEntity {
        
        let data = try await kakoLoginService.loginWithKakao()
        let loginInfo = try await authRepository.requestKakaoLogin(data)
        _ = tokenService.saveTokens(accessToken: loginInfo.accessToken, refreshToken: loginInfo.refreshToken)
        
        return loginInfo.toEntity()
    }
}

// MARK: 애플 로그인
final class DefaultAppleLoginUseCase: AppleLoginUseCase {
    
    private let appleLoginService: SocialLoginService
    private let authRepository: AppleLoginRepository
    private let tokenService: TokenWritable
    
    init(appleLoginService: SocialLoginService, authRepository: AppleLoginRepository, tokenService: TokenWritable) {
        self.appleLoginService = appleLoginService
        self.authRepository = authRepository
        self.tokenService = tokenService
    }
    
    
}
// MARK: Login
extension DefaultAppleLoginUseCase {
    
    
    func execute(_ result:  Result<ASAuthorization, any Error>) async throws -> UserEntity {
        
        let data = try await appleLoginService.loginWithApple(result)
        let loginInfo = try await authRepository.requestAppleLogin(data.token, data.name)
        _ = tokenService.saveTokens(accessToken: loginInfo.accessToken, refreshToken: loginInfo.refreshToken)
        
        return loginInfo.toEntity()
        
    }
}


// MARK: 이메일 로그인
final class DefaultEmailLoginUseCase: EmailLoginUseCase {
    
    private let authRepository: EmailLoginRepository
    private let tokenService: TokenWritable
    
    
    
    init(authRepository: EmailLoginRepository, tokenService: TokenWritable) {
        self.authRepository = authRepository
        self.tokenService = tokenService
    }
    
}
extension DefaultEmailLoginUseCase {
    
    
    func execute(email: String, password: String, deviceToken: String?) async throws -> UserEntity {
        
        let loginInfo = try await authRepository.requestEmailLogin(email, password, deviceToken)
        
        _ = tokenService.saveTokens(accessToken: loginInfo.accessToken, refreshToken: loginInfo.refreshToken)
        
        return loginInfo.toEntity()
        
        
    }
    
    
}

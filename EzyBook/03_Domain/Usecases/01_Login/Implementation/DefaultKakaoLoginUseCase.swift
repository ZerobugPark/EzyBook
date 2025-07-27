//
//  DefaultKakaoLoginUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import Foundation

final class DefaultKakaoLoginUseCase: KakaoLogin {
    
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
        
        do {
            let data = try await kakoLoginService.loginWithKakao()
            let loginInfo = try await authRepository.requestKakaoLogin(data)
            _ = tokenService.saveTokens(accessToken: loginInfo.accessToken, refreshToken: loginInfo.refreshToken)
            
            return loginInfo.toEntity()
        } catch {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
    }
}







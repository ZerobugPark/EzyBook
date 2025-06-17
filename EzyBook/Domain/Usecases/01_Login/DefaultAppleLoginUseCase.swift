//
//  DefaultAppleLoginUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import AuthenticationServices
import Foundation

final class DefaultAppleLoginUseCase {
    
    // 여기는 카카오 로그인과, apple 로그인이 필요
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
    
    
    func execute(_ result:  Result<ASAuthorization, any Error>) async throws -> Void {
        
        do {
            let data = try await appleLoginService.loginWithApple(result)
            let token = try await authRepository.requestAppleLogin(data.token, data.name)
            _ = tokenService.saveTokens(accessToken: token.accessToken, refreshToken: token.refreshToken)
            
        }    catch {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
    }
}







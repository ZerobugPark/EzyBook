//
//  DefaultAppleLoginUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import AuthenticationServices
import Foundation

final class DefaultAppleLoginUseCase: AppleLogin {

    
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
        
        do {
            let data = try await appleLoginService.loginWithApple(result)
            let loginInfo = try await authRepository.requestAppleLogin(data.token, data.name)
            _ = tokenService.saveTokens(accessToken: loginInfo.accessToken, refreshToken: loginInfo.refreshToken)
            
            return loginInfo.toEntity()
            
        }    catch {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
    }
}







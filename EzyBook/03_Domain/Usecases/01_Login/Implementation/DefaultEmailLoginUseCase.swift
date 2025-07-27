//
//  DefaultLoginUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import Foundation

final class DefaultEmailLoginUseCase {
    
    private let authRepository: EmailLoginRepository
    private let tokenService: TokenWritable
    
    init(authRepository: EmailLoginRepository, tokenService: TokenWritable) {
        self.authRepository = authRepository
        self.tokenService = tokenService
    }
    
}

// MARK: Lgoin

extension DefaultEmailLoginUseCase {
    
    
    func execute(email: String, password: String) async throws -> UserEntity {
        
        let requestDto = EmailLoginRequestDTO(email: email, password: password, deviceToken: nil)
        
        let router = UserRequest.Post.emailLogin(body: requestDto)
        do {
            let loginInfo = try await authRepository.requestEmailLogin(router)
            _ = tokenService.saveTokens(accessToken: loginInfo.accessToken, refreshToken: loginInfo.refreshToken)
            
            return loginInfo.toEntity()
        } catch  {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
            
        }
        
    }
}


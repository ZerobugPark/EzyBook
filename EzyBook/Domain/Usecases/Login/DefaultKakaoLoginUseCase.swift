//
//  DefaultKakaoLoginUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import Foundation

final class DefaultKakaoLoginUseCase {
    
    // 여기는 카카오 로그인과, apple 로그인이 필요
    private let kakoLoginService: SocialLoginService
    private let authRepository: KakaoLoginRepository
    private let tokenService: TokenService
    
    init(kakoLoginService: SocialLoginService, authRepository: KakaoLoginRepository, tokenService: TokenService) {
        self.kakoLoginService = kakoLoginService
        self.authRepository = authRepository
        self.tokenService = tokenService
    }
    
    
}

// MARK: Login
extension DefaultKakaoLoginUseCase {
    
    func execute(completionHandler: @escaping (Result <Void, APIError>) -> Void) {
        Task {
            do {
                let data = try await kakoLoginService.loginWithKakao()
                let token = try await authRepository.requestKakaoLogin(data)
                _ = tokenService.saveTokens(accessToken: token.accessToken, refreshToken: token.refreshToken)
                await MainActor.run {
                    completionHandler(.success(()))
                }
            } catch  {
                let resolvedError: APIError
                if let apiError = error as? APIError {
                    resolvedError = apiError
                } else {
                    resolvedError = .unknown
                }
                await MainActor.run {
                    completionHandler(.failure(resolvedError))
                }
                
            }
        }
    }
}






//
//  DefaultAppleLoginUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import Foundation

final class DefaultAppleLoginUseCase {
    
    // 여기는 카카오 로그인과, apple 로그인이 필요
    private let appleLoginService: SocialLoginService
    private let authRepository: AppleLoginRepository
    private let tokenService: TokenService
    
    init(appleLoginService: SocialLoginService, authRepository: AppleLoginRepository, tokenService: TokenService) {
        self.appleLoginService = appleLoginService
        self.authRepository = authRepository
        self.tokenService = tokenService
    }
    
    
}

// MARK: Login
extension DefaultAppleLoginUseCase {
    
    func execute(completionHandler: @escaping (Result <Void, APIError>) -> Void) {
        Task {
            do {
                let data = try await appleLoginService.appleLogin()
                let token = try await authRepository.loingWithApple(data)
                completionHandler(.success(()))
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






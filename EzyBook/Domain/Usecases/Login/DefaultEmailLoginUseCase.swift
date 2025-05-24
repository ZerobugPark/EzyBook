//
//  DefaultLoginUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import Foundation

final class DefaultEmailLoginUseCase {

    private let authRepository: EmailLoginRepository
    private let tokenService: TokenService
    
    init(authRepository: EmailLoginRepository, tokenService: TokenService) {
        self.authRepository = authRepository
        self.tokenService = tokenService
    }
    
}

// MARK: Lgoin

extension DefaultEmailLoginUseCase {
    
    func emailLogin (email: String, password: String, completionHandler: @escaping (Result <Void, APIError>) -> Void) {
        
        let requestDto = EmailLoginRequestDTO(email: email, password: password, deviceToken: nil)

        let router = UserPostRequest.emailLogin(body: requestDto)
        
        Task {
            do {
               let token = try await authRepository.requestEmailLogin(router)
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

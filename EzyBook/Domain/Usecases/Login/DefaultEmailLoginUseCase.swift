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

        let router = UserRequest.emailLogin(body: requestDto)
        
        Task {
            do {
               let _ = try await authRepository.emailLogin(router)
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

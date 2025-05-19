//
//  DefaultLoginUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import Foundation

final class DefaultLoginUseCase {

    private let authNetworkRepository: AuthNetworkRepository
    
    init(authNetworkRepository: AuthNetworkRepository) {
        self.authNetworkRepository = authNetworkRepository
    }
    
}

// MARK: Lgoin

extension DefaultLoginUseCase {
    
    func emailLogin (email: String, password: String, completionHandler: @escaping (Result <Void, APIError>) -> Void) {
        
        let requestDto = EmailLoginRequestDTO(email: email, password: password, deviceToken: nil)
        
        let router = UserRequest.emailLogin(body: requestDto)
        
        Task {
            do {
                try await authNetworkRepository.emailLogin(router)
                completionHandler(.success(()))
            } catch  {
                if let apiError = error as? APIError {
                    completionHandler(.failure(apiError))
                } else {
                    completionHandler(.failure(.unknown))
                }
            }
        }
    }
}

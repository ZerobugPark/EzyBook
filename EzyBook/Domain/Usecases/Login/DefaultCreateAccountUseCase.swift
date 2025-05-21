//
//  DefaultCreateAccountUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import Foundation

final class DefaultCreateAccountUseCase {
    
    private let authRepository: SignUpRepository

    init(authRepository: SignUpRepository) {
        self.authRepository = authRepository
    }
}

// MARK: Login
extension DefaultCreateAccountUseCase {
    
    func verifyEmail(_ email: String, completionHandler: @escaping (Result <Void, APIError>) -> Void) {
        Task {
            do {
                let _ = try await authRepository.verifyEmailAvailability(email)
                await MainActor.run {
                    completionHandler(.success(()))
                }
            } catch  {


            }
        }
    }
    
    func signUp(_ rotuer: UserRequest, completionHandler: @escaping (Result <Void, APIError>) -> Void) {
        Task {
            do {
                let _ = try await authRepository.signUp(rotuer)
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

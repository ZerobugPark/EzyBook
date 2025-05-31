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
    
    func verifyEmail(_ email: String) async throws -> Void {
        
        do {
            try await authRepository.verifyEmailAvailability(email)
        } catch {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
        
    }
    
    func signUp(_ rotuer: UserPostRequest) async throws -> Void {
        
        do {
            try await authRepository.signUp(rotuer)
        }
        catch {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
        
    }
}

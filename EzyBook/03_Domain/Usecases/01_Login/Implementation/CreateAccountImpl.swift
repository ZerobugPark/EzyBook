//
//  CreateAccountImpl.swift
//  EzyBook
//
//  Created by youngkyun park on 7/22/25.
//

import Foundation

// MARK: 회원가입
final class DefaultSignUpUseCase: SignUpUseCase {
    
    private let authRepository: SignUpRepository
    
    init(authRepository: SignUpRepository) {
        self.authRepository = authRepository
    }
}

extension DefaultSignUpUseCase {
    
    func execute(email: String, password: String, nick: String, phoneNum: String?, introduction: String?, deviceToken: String?) async throws -> Void {
        
        do {
            try await authRepository.signUp(
                email,
                password,
                nick,
                phoneNum,
                introduction,
                deviceToken
            )
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


// MARK: 이메일 유효성 검사
final class DefaultVerifyEmailUseCase: VerifyEmailUseCase {
    
    private let authRepository: SignUpRepository
    
    init(authRepository: SignUpRepository) {
        self.authRepository = authRepository
    }
    
}

extension DefaultVerifyEmailUseCase {
    
    func execute(_ email: String) async throws -> Void {
        
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
    
}

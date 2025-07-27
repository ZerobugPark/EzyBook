//
//  CreateAccountImpl.swift
//  EzyBook
//
//  Created by youngkyun park on 7/27/25.
//

import Foundation

// MARK: 계정 생성
final class DefaultCreateAccountUseCase: SignUpUseCase {

    private let authRepository: SignUpRepository
    
    init(authRepository: SignUpRepository) {
        self.authRepository = authRepository
    }
}


extension DefaultCreateAccountUseCase {
    
    func execute(email: String, password: String, nick: String, phoneNum: String?, introduction: String?, deviceToken: String?) async throws {
        
        try await authRepository.signUp(email, password, nick, phoneNum, introduction, deviceToken)

    }
    

}

// MARK: 이메일 중복 확인
final class DefaultVerifyEmailUseCase: VerifyEmailUseCase {

    private let authRepository: VerifyEmailRepository
    
    init(authRepository: VerifyEmailRepository) {
        self.authRepository = authRepository
    }
}

extension DefaultVerifyEmailUseCase {
    func execute(_ email: String) async throws {
        try await authRepository.verifyEmailAvailability(email)
    }
    
}



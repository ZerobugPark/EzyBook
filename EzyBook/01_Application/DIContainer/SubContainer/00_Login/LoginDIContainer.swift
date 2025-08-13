//
//  LoginDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 7/27/25.
//

import Foundation

protocol LoginFactory {
    func makeAccountViewModel() -> CreateAccountViewModel
    func makeEmailLoginViewModel() -> EmailLoginViewModel
    func makeSocialLoginViewModel() -> LoginViewModel
}

final class LoginDIContainer {
    
    private let networkService: DefaultNetworkService
    private let tokenService: DefaultTokenService
    
    init(networkService: DefaultNetworkService, tokenService: DefaultTokenService) {
        self.networkService = networkService
        self.tokenService = tokenService
    }
    
    func makeFactory() -> LoginFactory { Impl(container: self) }
    
    private final class Impl: LoginFactory {
        
        private let container: LoginDIContainer
        init(container: LoginDIContainer) { self.container = container }
        
        
        func makeAccountViewModel() -> CreateAccountViewModel {
            CreateAccountViewModel(createUseCases: container.makeCreateAccountUseCase())
        }
        
        func makeEmailLoginViewModel() -> EmailLoginViewModel {
            EmailLoginViewModel(emailLoginUseCase: container.makeEmailLoginUseCase())
        }
        
        func makeSocialLoginViewModel() -> LoginViewModel {
            LoginViewModel(socialLoginUseCases: container.makeSocialLoginUseCase())
        }
        
    }
    
}
// MARK: Maek Auth UseCase
extension LoginDIContainer {
    
    
    // MARK: Make Bundle
    private func makeSocialLoginUseCase() -> SocialLoginUseCases {
        SocialLoginUseCases(
            appleLogin: makeAppleLoginUseCase(),
            kakaoLogin: makeKakaoLoginUseCase()
        )
    }
    
    private func makeCreateAccountUseCase() -> CreateAccountUseCases {
        CreateAccountUseCases(
            signUp: makeSignUpUseCase(),
            verifyEmail: makeVerifyEmailUseCase()
        )
    }
    
    
    // MARK: UseCase
    private func makeKakaoLoginUseCase() -> DefaultKakaoLoginUseCase {
        DefaultKakaoLoginUseCase(
            kakoLoginService: makeSocialLoginService(),
            authRepository: makeAuthRepository(),
            tokenService: tokenService
        )
    }
    private func makeAppleLoginUseCase() -> DefaultAppleLoginUseCase {
        DefaultAppleLoginUseCase(
            appleLoginService: makeSocialLoginService(),
            authRepository: makeAuthRepository(),
            tokenService: tokenService
        )
    }

    private func makeEmailLoginUseCase() -> EmailLoginUseCase {
        DefaultEmailLoginUseCase(
            authRepository: makeAuthRepository(),
            tokenService: tokenService)
    }
    
    private func makeSignUpUseCase() -> SignUpUseCase {
        DefaultCreateAccountUseCase(authRepository: makeAuthRepository())
    }
    
    private func makeVerifyEmailUseCase() -> VerifyEmailUseCase {
        DefaultVerifyEmailUseCase(authRepository: makeAuthRepository())
    }


}

// MARK: Data
extension LoginDIContainer {
    
    private func makeAuthRepository() -> DefaultAuthRepository {
        DefaultAuthRepository(networkService: networkService)
    }

    private func makeSocialLoginService() -> DefaultSocialLoginService {
        DefaultSocialLoginService()
    }
}

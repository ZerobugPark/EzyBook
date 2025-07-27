//
//  LoginDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 7/22/25.
//

import Foundation


/// 동일 인스턴스가 필요한 경우 lazy var로 선언
/// 그 외 함수로 처리

final class LoginDIContainer {
    
    private let networkService: DefaultNetworkService
    private let tokenService: DefaultTokenService
    
    init(networkService: DefaultNetworkService, tokenService: DefaultTokenService) {
        self.networkService = networkService
        self.tokenService = tokenService
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
            tokenService: tokenService
        )
    }

    private func makeSignUpUseCase() -> DefaultSignUpUseCase {
        DefaultSignUpUseCase(authRepository: makeAuthRepository())
    }
    
    private func makeVerifyEmailUseCase() -> DefaultVerifyEmailUseCase {
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






// MARK: Make Auth ViewModel
extension LoginDIContainer {
    
    func makeAccountViewModel() -> CreateAccountViewModel {
        CreateAccountViewModel(createUseCase: makeCreateAccountUseCase())
    }
    
    func makeEmailLoginViewModel() -> EmailLoginViewModel {
        EmailLoginViewModel(emailLoginUseCase: makeEmailLoginUseCase())
    }
    
    func makeSocialLoginViewModel() -> LoginViewModel {
        LoginViewModel(socialLoginUseCases: makeSocialLoginUseCase())
    }
    
}

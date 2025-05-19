//
//  DIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 5/14/25.
//

import Foundation

///
/// 공통 모듈
/// 네트워크 서비스?, 저장소 패턴, 또 뭐가 있을끼?

final class DIContainer: ObservableObject {

    private let authNetworkRepository: AuthNetworkRepository
    private let socialUseCase: DefaultSocialLoginUseCase

    
    init(authNetworkRepository: AuthNetworkRepository, socialUseCase: DefaultSocialLoginUseCase) {
        self.authNetworkRepository = authNetworkRepository
        self.socialUseCase = socialUseCase
    }
        
}

// MARK: Make ViewModel
extension DIContainer {
//    func makeAccountViewModel() -> CreateAccountViewModel {
//        return CreateAccountViewModel(newtworkRepository: networkRepository)
//    }
//    
//    func makeEmailLoginViewModel() -> EmailLoginViewModel {
//        return EmailLoginViewModel(newtworkRepository: networkRepository, tokenManager: tokenManager)
//    }
    
//    func makeLoginViewModel(for type: LoginType) -> LoginViewModel {
//        switch type {
//        case let .email(email, password):
//            let useCase = EmailLoginUseCase(...)
//            return LoginViewModel(loginUseCase: useCase)
//        case .kakao:
//            let useCase = SocialLoginUseCase(provider: .kakao, ...)
//            return LoginViewModel(loginUseCase: useCase)
//        case .apple:
//            let useCase = SocialLoginUseCase(provider: .apple, ...)
//            return LoginViewModel(loginUseCase: useCase)
//        }
//    }
    
    func makeSocialLoginViewModel() -> SocialLoginViewModel {
        return SocialLoginViewModel(useCase: socialUseCase)
    }

}

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

    
    private let socialUseCase: DefaultSocialLoginUseCase
    private let emailLoginUseCase: DefaultLoginUseCase
    private let createAccounUseCase: DefaultCreateAccountUseCase
    
    init(socialUseCase: DefaultSocialLoginUseCase, emailLoginUseCase: DefaultLoginUseCase, createAccounUseCase: DefaultCreateAccountUseCase) {
        self.socialUseCase = socialUseCase
        self.emailLoginUseCase = emailLoginUseCase
        self.createAccounUseCase = createAccounUseCase
    }
        
}

// MARK: Make ViewModel
extension DIContainer {
    func makeAccountViewModel() -> CreateAccountViewModel {
        return CreateAccountViewModel(createUseCase: createAccounUseCase)
    }
    
    func makeEmailLoginViewModel() -> EmailLoginViewModel {
        return EmailLoginViewModel(emailLoginUseCase: emailLoginUseCase)
    }
    
    func makeSocialLoginViewModel() -> SocialLoginViewModel {
        return SocialLoginViewModel(useCase: socialUseCase)
    }

}

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

    /// Auth
    private let kakaoLoginUseCase: DefaultKakaoLoginUseCase
    private let createAccountUseCase : DefaultCreateAccountUseCase
    private let emailLoginUseCase : DefaultEmailLoginUseCase
    private let appleLoginUseCase: DefaultAppleLoginUseCase
    
    
    /// Activity
    let activityListUseCase: DefaultActivityListUseCase
    let activityNewListUseCase: DefaultNewActivityListUseCase
    let activitySearchUseCase: DefaultActivitySearchUseCase

    
    init(kakaoLoginUseCase: DefaultKakaoLoginUseCase, createAccountUseCase: DefaultCreateAccountUseCase, emailLoginUseCase: DefaultEmailLoginUseCase, appleLoginUseCase: DefaultAppleLoginUseCase, activityListUseCase: DefaultActivityListUseCase, activityNewListUseCase: DefaultNewActivityListUseCase, activitySearchUseCase: DefaultActivitySearchUseCase) {
        self.kakaoLoginUseCase = kakaoLoginUseCase
        self.createAccountUseCase = createAccountUseCase
        self.emailLoginUseCase = emailLoginUseCase
        self.appleLoginUseCase = appleLoginUseCase
        self.activityListUseCase = activityListUseCase
        self.activityNewListUseCase = activityNewListUseCase
        self.activitySearchUseCase = activitySearchUseCase
    }
    
        
}

// MARK: Make Auth ViewModel
extension DIContainer {
    func makeAccountViewModel() -> CreateAccountViewModel {
        return CreateAccountViewModel(createUseCase: createAccountUseCase)
    }
    
    func makeEmailLoginViewModel() -> EmailLoginViewModel {
        return EmailLoginViewModel(emailLoginUseCase: emailLoginUseCase)
    }
    
    func makeSocialLoginViewModel() -> LoginViewModel {
        return LoginViewModel(
            kakaoLoginUseCase: kakaoLoginUseCase,
            appleLoginUseCase: appleLoginUseCase
        )
    }

}

// MARK: Make Home ViewModel
extension DIContainer {
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            activityListUseCase: activityListUseCase,
            activityNewLisUsecaset: activityNewListUseCase
        )
    }
}

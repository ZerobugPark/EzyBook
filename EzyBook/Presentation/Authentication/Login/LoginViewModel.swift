//
//  SocialLoginViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 5/19/25.
//

import AuthenticationServices
import SwiftUI
import Combine


final class LoginViewModel: ViewModelType {
    
    private let kakaoLoginUseCase: DefaultKakaoLoginUseCase
    private let appleLoginUseCase: DefaultAppleLoginUseCase
    
    var input = Input()
    @Published var output = Output()
        
    var cancellables = Set<AnyCancellable>()
    
    init(kakaoLoginUseCase: DefaultKakaoLoginUseCase, appleLoginUseCase: DefaultAppleLoginUseCase) {
        self.kakaoLoginUseCase = kakaoLoginUseCase
        self.appleLoginUseCase = appleLoginUseCase
        transform()
    }
}

// MARK: Input/Output
extension LoginViewModel {
    
    struct Input { }
    
    struct Output { }
    
    func transform() { }
    
    private func handleKakaoLoginResult() {
        kakaoLoginUseCase.execute { result in
            switch result {
            case .success(_):
                break
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func configureAppleLoginRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.email, .fullName]
    }
    
    private func handleAppleLoginResult(_ result: Result<ASAuthorization, any Error>) {
        appleLoginUseCase.execute(result) { result in
            switch result {
            case .success(_):
                break
            case .failure(let failure):
                print(failure)
            }
        }
    }
  
}

// MARK: Action
extension LoginViewModel {
    
    enum Action {
        case kakaoLoginButtonTapped
        case appleLoginButtonTapped(reqeust: ASAuthorizationAppleIDRequest)
        case appleLoginCompleted(result: Result<ASAuthorization, any Error>)
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .kakaoLoginButtonTapped:
            handleKakaoLoginResult()
        case .appleLoginButtonTapped(let request):
            configureAppleLoginRequest(request)
        case .appleLoginCompleted(let result):
            handleAppleLoginResult(result)
        }
    }
}




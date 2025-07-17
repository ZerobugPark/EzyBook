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
    
    private let socialLoginUseCases: SocialLoginUseCases
    
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    init(socialLoginUseCases: SocialLoginUseCases) {
        self.socialLoginUseCases = socialLoginUseCases
        transform()
    }
}

// MARK: Input/Output
extension LoginViewModel {
    
    struct Input { }
    
    struct Output {
        var loginError: LoginFlowError? = nil
        var isShowingError: Bool {
            loginError != nil
        }
        var loginSuccessed = false
    }
    
    func transform() { }
    
    private func requestKakaoLogin() {
        
        Task {
            do {
                let data = try await socialLoginUseCases.kakaoLogin.execute()
                
                /// 유저 정보 업데이트
                UserSession.shared.update(data)
                
                await MainActor.run {
                    output.loginSuccessed = true
                }
            } catch let error as APIError {
                await MainActor.run {
                    self.output.loginError = .kakaoLoginError(code: error.code)
                }
            }
        }
    }
    
    /// 애플 로그인 권한 설정
    private func configureAppleLoginRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.email, .fullName]
    }
    
    private func requestAppleLogin(_ result: Result<ASAuthorization, any Error>) {
        Task {
            do {
                let data = try await socialLoginUseCases.appleLogin.execute(result)
                
                /// 유저 정보 업데이트
                UserSession.shared.update(data)
                
                await MainActor.run {
                    output.loginSuccessed = true
                }
            } catch let error as APIError {
                await MainActor.run {
                    self.output.loginError = .kakaoLoginError(code: error.code)
                }
            }
        }
    }
    
    private func handleResetError() {
        output.loginError = nil
    }
}

// MARK: Action
extension LoginViewModel {
    
    enum Action {
        case kakaoLoginButtonTapped
        case appleLoginButtonTapped(reqeust: ASAuthorizationAppleIDRequest)
        case appleLoginCompleted(result: Result<ASAuthorization, any Error>)
        case resetError
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .kakaoLoginButtonTapped:
            requestKakaoLogin()
        case .appleLoginButtonTapped(let request):
            configureAppleLoginRequest(request)
        case .appleLoginCompleted(let result):
            requestAppleLogin(result)
        case .resetError:
            handleResetError()
        }
    }
}




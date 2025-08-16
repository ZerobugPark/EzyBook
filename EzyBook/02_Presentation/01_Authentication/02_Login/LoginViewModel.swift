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
        
        print(#function, Self.desc)
    }
    
    deinit {
        print(#function, Self.desc)
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
 
    
    private func handleResetError() {
        output.loginError = nil
    }
}

// MARK: KaKaoLogin
extension LoginViewModel {
    private func handleKakaoLogin() {
        
        Task {
            await performKakaoLogin()
        }
    }
    
    private func performKakaoLogin() async {
        
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
        } catch {
            print(#function, error)
        }
        
    }
}

// MARK: Apple Login

extension LoginViewModel {
    
    private func handleAppleLoginRequest(_ request: ASAuthorizationAppleIDRequest) {
        configureAppleLoginRequest(request)
    }
    
    /// 애플 로그인 권한 설정
    private func configureAppleLoginRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.email, .fullName]
    }
    
    private func handleAppleLoginCompleted(_ result: Result<ASAuthorization, any Error>) {
        
        Task {
            await performAppleLogin(result)
        }
        
    }
    
    private func performAppleLogin(_ result: Result<ASAuthorization, any Error>)  async {
        do {
            let data = try await socialLoginUseCases.appleLogin.execute(result)
            
            /// 유저 정보 업데이트
            UserSession.shared.update(data)
            
            await MainActor.run {
                output.loginSuccessed = true
            }
        } catch let error as APIError {
            await MainActor.run {
                self.output.loginError = .appleLoginError(code: error.code)
            }
        } catch {
            print(#function, error)
        }
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
            handleKakaoLogin()
        case .appleLoginButtonTapped(let request):
            handleAppleLoginRequest(request)
        case .appleLoginCompleted(let result):
            handleAppleLoginCompleted(result)
        case .resetError:
            handleResetError()
        }
    }
}




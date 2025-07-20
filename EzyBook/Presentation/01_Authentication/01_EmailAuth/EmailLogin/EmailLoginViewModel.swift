//
//  EmailLoginViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import SwiftUI
import Combine


final class EmailLoginViewModel: ViewModelType {
    
    let emailLoginUseCase: DefaultEmailLoginUseCase
    
    var input = Input()
    @Published var output = Output()
        
    var cancellables = Set<AnyCancellable>()
    
    init(emailLoginUseCase: DefaultEmailLoginUseCase) {
        self.emailLoginUseCase = emailLoginUseCase
        transform()
    }
}

// MARK: Input/Output
extension EmailLoginViewModel {
    
    struct Input {
        var emailTextField = ""
        var passwordTextField = ""
    }
    
    struct Output {
        var loginError: LoginFlowError? = nil
        var isShowingError: Bool {
            loginError != nil
        }
        var loginSuccessed = false
    }
    
    func transform() { }
    
  
    private func requestLogin() {
        
        guard input.emailTextField.validateEmail() else {
            output.loginError = .emailInvalidFormat
            return
        }

        guard input.passwordTextField.validatePasswordLength(),
              input.passwordTextField.validatePasswordCmplexEnough() else {
            output.loginError = .passwordInvalidFormat
            return
        }

        Task {
            do {
                let data = try await emailLoginUseCase.execute(email: input.emailTextField, password: input.passwordTextField)
                
                UserSession.shared.update(data)
                
                await MainActor.run {
                    self.output.loginSuccessed = true
                }
            } catch let error as APIError {
                await MainActor.run {
                    self.output.loginError = .serverError(.error(code: error.code, msg: error.userMessage))
                }
            }
            
        }

        
    }
    private func handleResetError() {
        output.loginError = nil
    }
}

// MARK: Action
extension EmailLoginViewModel {
    
    enum Action {
        case logunButtonTapped
        case resetError
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .logunButtonTapped:
            requestLogin()
        case .resetError:
            handleResetError()
        }
    }
}




//
//  EmailLoginViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import SwiftUI
import Combine


final class EmailLoginViewModel: ViewModelType {
    
    var newtworkRepository: NetworkRepository
    var input = Input()
    @Published var output = Output()
        
    var cancellables = Set<AnyCancellable>()
    
    init(newtworkRepository: NetworkRepository) {
        self.newtworkRepository = newtworkRepository
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
        var loginError: LoginError? = nil
        var isShowingError: Bool {
            loginError != nil
        }

    }
    
    func transform() { }
    
  
    private func handleLogin() {
        
        guard input.emailTextField.validateEmail() else {
            output.loginError = .emailInvalidFormat
            return
        }

        guard input.passwordTextField.validatePasswordLength(),
              input.passwordTextField.validatePasswordCmplexEnough() else {
            output.loginError = .passwordInvalidFormat
            return
        }

        let body = EmailLoginRequestDTO(email: input.emailTextField, password: input.passwordTextField, deviceToken: nil)
        let router = UserRequest.emailLogin(body: body)

        newtworkRepository.fetchData(dto: LoginResponseDTO.self, router) { [weak self] (result: Result<LoginEntity, APIError>) in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                print("로그인 성공: \(data)")
                // TODO: 토큰 저장, 화면 전환 등
            case .failure(let err):
                output.loginError = .serverError(.error(code: err.code, msg: err.userMessage))
            }
        }
        
    }
    private func handlerResetError() {
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
            handleLogin()
        case .resetError:
            handlerResetError()
        }
    }
}




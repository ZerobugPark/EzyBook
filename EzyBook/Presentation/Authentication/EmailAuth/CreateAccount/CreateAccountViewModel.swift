//
//  CreateAccountViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI
import Combine

final class CreateAccountViewModel: ViewModelType {
    
    var createUseCase: DefaultCreateAccountUseCase
    var input = Input()
    @Published var output = Output()
    
    @Published var phoneNumberTextField: String {
        didSet {
            // phoneNumberTextField 변경 시 input 안에 값도 갱신
            input.phoneNumberTextField = phoneNumberTextField
        }
    }
        
    var cancellables = Set<AnyCancellable>()
    
    init(createUseCase: DefaultCreateAccountUseCase) {
        self.createUseCase = createUseCase
        self.phoneNumberTextField = input.phoneNumberTextField
        transform()
    }
    
    
}

// MARK: Input/Output
extension CreateAccountViewModel {
        
    /// 비밀번호 일치 여부 (사용 가능 여부)
    var validatePassword: Bool {
        return input.passwordTextField == input.passwordConfirmTextField
    }
    
    /// 닉네임 유효성 검사
    var vaildationNicknameValid: Bool {
        let forbiddenCharacters: Set<Character> = [",", ".", "?", "*", "-", "@"]
        let input = input.nicknameTextField.trimmingCharacters(in: .whitespaces)
        
        if input.isEmpty {
            return false
        }
        
        if input.count == 1, let firstChar = input.first, forbiddenCharacters.contains(firstChar) {
            return false
        }
        
        return true
    }
    
    var vaildationPhoneNumber: Bool {
        return input.phoneNumberTextField.count == 11
    }
    
    struct Input {
        var emailTextField = ""
        var passwordTextField = ""
        var passwordConfirmTextField = ""
        var nicknameTextField = ""
        var phoneNumberTextField = ""
        var introduceTextField = ""
    }
    
    struct Output {
        var isVaildEmail = false
        var isAvailableEmail = false
        var isPasswordLongEnough = false
        var isPasswordComplexEnough = false
        var isValidPassword = false
        var isValidNickname = false
        var isValidPhoneNumber = false
        var isFormValid = false
        var currentError: DisplayError? = nil
        var isAccountCreated = false
        
        // 비밀번호 히든 체크
        var visibleStates: [PasswordInputFieldType: Bool] = [
            .password: false,
            .confirmPassword: false
        ]
        
        var isShowingError: Bool {
            currentError != nil
        }


    }
    
    func transform() { }
    
    /// 이메일 유효성 검사 및 중복확인
    private func handleEmailEditingCompleted() {
        output.isVaildEmail =  input.emailTextField.validateEmail()
        
        if output.isVaildEmail {
            createUseCase.verifyEmailAvailability(input.emailTextField) { result in
                switch result {
                case .success(_):
                    self.output.isAvailableEmail = true
                case .failure(let failure):
                    self.output.isAvailableEmail = false
                    self.output.currentError = .error(code: failure.code, msg: failure.userMessage)
                }
            }
        }
        
        updateFormValidation()
    }
    
    /// 텍스트필트 비밀번호 필드 히든 처리
    ///
    /// - Parameters:
    ///   - field: 텍트스필드 타입
    private func handleToggleVisibility(for field: PasswordInputFieldType) {
        output.visibleStates[field]?.toggle()
    }
    
    
    /// 비밀번호 필드, 유효성 검사
    private func handlePasswordEditingCompleted() {
        output.isPasswordLongEnough = input.passwordTextField.validatePasswordLength()
        output.isPasswordComplexEnough = input.passwordTextField.validatePasswordCmplexEnough()
       
        if output.isPasswordLongEnough && output.isPasswordComplexEnough {
            output.isValidPassword = validatePassword
        }
        
        updateFormValidation()
    }
    
    /// 닉네임 유효성 검사
    private func handlerNickNameEditingCompleted() {
        output.isValidNickname = vaildationNicknameValid
        updateFormValidation()
    }
    
    /// 휴대전화 유효성 검사
    private func handlerPhoneNumberEditingCompleted() {
        output.isValidPhoneNumber = vaildationPhoneNumber
    }
    
    private func handleSignUp() {
        
        let body = JoinRequestDTO(
            email: input.emailTextField,
            password: input.passwordConfirmTextField,
            nick: input.nicknameTextField,
            phoneNum: input.phoneNumberTextField.isEmpty ? nil : input.phoneNumberTextField,
            introduction: input.introduceTextField.isEmpty ? nil : input.introduceTextField,
            deviceToken: nil
        )
        let router = UserRequest.join(body: body)
        
        createUseCase.signUp(router) { result in
            switch result {
            case .success(_):
                self.output.isAccountCreated = true
            case .failure(let failure):
                self.output.currentError = .error(code: failure.code, msg: failure.userMessage)
            }
        }
    }
    
    /// 회원가입 버튼 버튼 상태
    private func updateFormValidation() {
        output.isFormValid = output.isVaildEmail && output.isAvailableEmail && output.isValidPassword && output.isValidNickname
    }
    
    private func handlerResetError() {
        output.currentError = nil
    }
    
    
}

// MARK: Action
extension CreateAccountViewModel {
    
    enum Action {
        case emailEditingCompleted
        case togglePasswordVisibility(type: PasswordInputFieldType)
        case passwordEditingCompleted
        case nickNameEditingCompleted
        case phoneNumberEditingCompleted
        case signUpButtonTapped
        case resetError
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
        func action(_ action: Action) {
        switch action {
        case .emailEditingCompleted:
            handleEmailEditingCompleted()
        case .togglePasswordVisibility(let type):
            handleToggleVisibility(for: type)
        case .passwordEditingCompleted:
            handlePasswordEditingCompleted()
        case .nickNameEditingCompleted:
            handlerNickNameEditingCompleted()
        case .phoneNumberEditingCompleted:
            handlerPhoneNumberEditingCompleted()
        case .signUpButtonTapped:
            handleSignUp()
        case .resetError:
            handlerResetError()
        }
    }
    
    
}

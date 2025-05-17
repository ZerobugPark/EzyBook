//
//  CreateAccountViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI
import Combine

final class CreateAccountViewModel: ViewModelType {
    
    var newtworkRepository: NetworkRepository
    var input = Input()
    @Published var output = Output()
    
    @Published var phoneNumberTextField: String {
        didSet {
            // phoneNumberTextField 변경 시 input 안에 값도 갱신
            input.phoneNumberTextField = phoneNumberTextField
        }
    }
    
    
    var cancellables = Set<AnyCancellable>()
    
    init(newtworkRepository: NetworkRepository) {
        self.newtworkRepository = newtworkRepository
        self.phoneNumberTextField = input.phoneNumberTextField
        transform()
    }
    
    
}

// MARK: Input/Output
extension CreateAccountViewModel {
    
    /// 이메일 유효성 검사 (서버에 있는데, 굳이 내가 체크를 할까?)
    /// ^:  문자열의 시작,
    /// [A-Z0-9a-z._%+-]+: 이메일의 앞 부분
    /// @: @기호 필수
    /// \. :도메인과 확장자 구분 및 Dot(.)필수
    /// [A-Za-z]{2,}: 도메인 확장자 (2글자 이상)
    /// $ 문자열 끝
    var validateEmail: Bool {
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: input.emailTextField)
    }
    
    
    /// 비밀번호 복잡도 검사
    var validatePasswordCmplexEnough: Bool {
        let regex = #"^(?=.*[a-zA-Z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]+$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: input.passwordTextField)
    }
    
    /// 비밀번호 길이 검사
    var validatePasswordLength: Bool {
        return input.passwordTextField.count > 7
    }
    
    /// 비밀번호 일치 여부 (사용 가능 여부
    var validatePassword: Bool {
        return input.passwordTextField == input.passwordConfirmTextField
    }
    
    /// 닉네임 유효성 검사
    var vaildationNicknameValid: Bool {
        let forbiddenCharacters: Set<Character> = [",", ".", "?", "*", "-", "@"]
        let input = input.nicknameTextField.trimmingCharacters(in: .whitespaces)
        
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
        var currentError: AppError? = nil
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
        output.isVaildEmail = validateEmail
        verifyEmailAvailability()
        updateFormValidation()
    }
    
    /// 텍스트필트 비밀번호 필드 히든 처리
    ///
    /// - Parameters:
    ///   - field: 텍트스필드 타입
    private func handleToggleVisibility(for field: PasswordInputFieldType) {
        output.visibleStates[field]?.toggle()
    }
    
    /// 이메일 중복확인 (서버 통신)
    private func verifyEmailAvailability() {
        
        let body = EmailValidationRequestDTO(email: input.emailTextField)
        let router = UserRequest.emailValidation(body: body)
        
        
        newtworkRepository.fetchData(dto: EmailValidationResponseDTO.self, router) { [weak self] (result: Result<EmailValidationEntity, APIError>) in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let success):
                print(success)
                output.isAvailableEmail = true
            case .failure(let failure):
                output.isAvailableEmail = false
                output.currentError = .error(code: failure.code, msg: failure.userMessage)
            }
        }
        
    }
    
    /// 비밀번호 필드, 유효성 검사
    private func handlePasswordEditingCompleted(for type: PasswordInputFieldType) {
        switch type {
        case .password:
            output.isPasswordLongEnough = validatePasswordLength
            output.isPasswordComplexEnough = validatePasswordCmplexEnough
        case .confirmPassword:
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
            phoneNum: input.phoneNumberTextField,
            introduction: input.introduceTextField,
            deviceToken: nil
        )
        let router = UserRequest.join(body: body)
        
        newtworkRepository.fetchData(dto: JoinResponseDTO.self, router) { [weak self] (result: Result<JoinEntity, APIError>) in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let success):
                print(success)
            case .failure(let failure):
                output.currentError = .error(code: failure.code, msg: failure.userMessage)
            }
        }
        
    }
    
    /// 회원가입 버튼 버튼 상태
    private func updateFormValidation() {
        output.isFormValid = output.isVaildEmail && output.isAvailableEmail && output.isValidPassword && output.isValidNickname
    }
    
    func resetError() {
        output.currentError = nil
    }
    
    
}

// MARK: Action
extension CreateAccountViewModel {
    
    enum Action {
        case emailEditingCompleted
        case togglePasswordVisibility(type: PasswordInputFieldType)
        case passwordEditingCompleted(type: PasswordInputFieldType)
        case nickNameEditingCompleted
        case phoneNumberEditingCompleted
        case signUpButtonTapped
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .emailEditingCompleted:
            handleEmailEditingCompleted()
        case .togglePasswordVisibility(let type):
            handleToggleVisibility(for: type)
        case .passwordEditingCompleted(let type):
            handlePasswordEditingCompleted(for: type)
        case .nickNameEditingCompleted:
            handlerNickNameEditingCompleted()
        case .phoneNumberEditingCompleted:
            handlerPhoneNumberEditingCompleted()
        case .signUpButtonTapped:
            handleSignUp()
        }
    }
    
    
}

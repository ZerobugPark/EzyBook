//
//  CreateAccountViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI
import Combine

final class CreateAccountViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    
        
    var cancellables = Set<AnyCancellable>()
    
    private let createUseCases: CreateAccountUseCases
    
    init(createUseCases: CreateAccountUseCases) {
        self.createUseCases = createUseCases
        transform()
    }
    
}

// MARK: Input/Output
extension CreateAccountViewModel {
        

    struct Input {
        var emailTextField = ""
        var passwordTextField = ""
        var passwordConfirmTextField = ""
        var nicknameTextField = ""
        var phoneNumberTextField = ""
        var introduceTextField = ""
    }
    
    struct Output {
        /// 뷰의 상태 표시
        var isVaildEmail = false
        var isAvailableEmail = false
        var isPasswordLongEnough = false
        var isPasswordComplexEnough = false
        var isValidPassword = false
        var isValidNickname = false
        var isValidPhoneNumber = false

        var presentedMessage: DisplayMessage? = nil
                
        var isFormValid: Bool {
            isVaildEmail && isAvailableEmail && isValidPassword && isValidNickname
        }
    
        
        var isShowingMessage: Bool {
            presentedMessage != nil
        }


    }
    
    func transform() { }
    
    
    /// 이거 특정 뷰모델로 처리해도 괜찮지 않을까?
    @MainActor
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            output.presentedMessage = DisplayMessage.error(code: apiError.code, msg: apiError.userMessage)
        } else {
            output.presentedMessage = DisplayMessage.error(code: -1, msg: error.localizedDescription)
        }
        
    }
    
    @MainActor
    private func handleSuccess() {
        output.presentedMessage = .success(msg: "회원가입이 완료되었습니다.")
    }
    


}

// MARK: Email TextField
extension CreateAccountViewModel {

    /// 이메일 유효성 검사 및 중복확인
    /// Validates email format and checks for duplication
    private func handleEmailEditingCompleted() {
        
        output.isVaildEmail = checkEmailFormat(input.emailTextField)

        if output.isVaildEmail {
            Task {
                await validateEmailAvailability()
            }
        }
    
    }
    
    /// 이메일(로컬) 유효성 검사
    /// Validates email (locally)
    private func checkEmailFormat(_ email: String) -> Bool {
        email.validateEmail()
    }
    
    /// 이메일 유효성 검사 및 중복 체크 (서버)
    /// Validates the email and checks for duplication on the server
    private func validateEmailAvailability() async {
        
        do {
            try await createUseCases.verifyEmail.execute(input.emailTextField)
           
            await MainActor.run {
                output.isAvailableEmail = true
            }
            
        } catch {
            output.isAvailableEmail = false
            await handleError(error)
        }
    }



}


// MARK: Password TextField
extension CreateAccountViewModel {
    /// 비밀번호 일치 여부 (사용 가능 여부)
    var isPasswordMatched: Bool {
        return input.passwordTextField == input.passwordConfirmTextField
    }
    
    /// 비밀번호 필드, 유효성 검사
    private func handlePasswordEditingCompleted() {
        output.isPasswordLongEnough = input.passwordTextField.validatePasswordLength()
        output.isPasswordComplexEnough = input.passwordTextField.validatePasswordCmplexEnough()
       
        if output.isPasswordLongEnough && output.isPasswordComplexEnough {
            output.isValidPassword = isPasswordMatched
        }
 
    }

}

// MARK: NickName TextField
extension CreateAccountViewModel {
    
    /// Validates NickName
    private func handleNicknameEditingCompleted() {
        output.isValidNickname = isNicknameLocallyValid(input.nicknameTextField)
    }
    
    /// 유저 닉네임 유효성 검사
    private func isNicknameLocallyValid(_ nickname: String) -> Bool {
        //유효한 특수문자
        let forbiddenCharacters: Set<Character> = [",", ".", "?", "*", "-", "@"]
        let trimmed = nickname.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty else { return false }
        if trimmed.count == 1, let first = trimmed.first, forbiddenCharacters.contains(first) {
            return false
        }
        return true
    }

    
}

// MARK: Phone Text Field
extension CreateAccountViewModel {
    

    /// Checks if the given phone number is valid (e.g., exactly 11 digits, etc.)
    private func isPhoneNumberValid(_ phoneNumber: String) -> Bool {
        // 1. 11자리, 2. 모두 숫자, 3. 01로 시작
        phoneNumber.count == 11 &&
        phoneNumber.hasPrefix("01") &&
        phoneNumber.allSatisfy { $0.isNumber }
    }
    
    /// Validate Phone Number
    private func handlePhoneNumberEditingCompleted() {
        output.isValidPhoneNumber = isPhoneNumberValid(input.phoneNumberTextField)
    }
    
}


// MARK: SignUp Button Tapped (회원가입 클릭)
extension CreateAccountViewModel {
    
    
    private func handleSignUpButtonTapped() {
        Task {
            await performSignUpRequest()
        }
    }
    
    private func performSignUpRequest() async {
        
        do {
            try await createUseCases.signUp.execute(
                email: input.emailTextField,
                password: input.passwordConfirmTextField,
                nick: input.nicknameTextField,
                phoneNum: input.phoneNumberTextField.isEmpty ? nil : input.phoneNumberTextField,
                introduction: input.introduceTextField.isEmpty ? nil : input.introduceTextField,
                deviceToken: nil
            )
                
            await MainActor.run {
                
                handleSuccess()
            }
        } catch {
            output.isAvailableEmail = false
            await handleError(error)
        }
        
    }

    
}



// MARK: Action
extension CreateAccountViewModel {
    
    enum Action {
        case emailEditingCompleted
        case passwordEditingCompleted
        case nickNameEditingCompleted
        case phoneNumberEditingCompleted
        case signUpButtonTapped
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
        func action(_ action: Action) {
        switch action {
        case .emailEditingCompleted:
            handleEmailEditingCompleted()
        case .passwordEditingCompleted:
            handlePasswordEditingCompleted()
        case .nickNameEditingCompleted:
            handleNicknameEditingCompleted()
        case .phoneNumberEditingCompleted:
            handlePhoneNumberEditingCompleted()
        case .signUpButtonTapped:
            handleSignUpButtonTapped()
        }
    }
    
    
}

// MARK: Alert 처리
extension CreateAccountViewModel: AnyObjectWithCommonUI {
    
    var isShowingError: Bool { output.isShowingMessage }
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    var isSuccessMessage: Bool { output.presentedMessage?.isSuccess ?? false }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
    
    
}

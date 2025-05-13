//
//  CreateAccountViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI
import Combine

/// 패스워드 텍스트 필드
enum PasswordField {
    case password
    case confirm
}

final class CreateAccountViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    
    @Published var phoneNumberTextField: String {
        didSet {
            // phoneNumberTextField 변경 시 input 안에 값도 갱신
            input.phoneNumberTextField = phoneNumberTextField
        }
    }
    
    
    //@Published var phoneNumberTextField: String = ""
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
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
        let regex = #"^[^,.\?\*@\-@]+$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: input.nicknameTextField)
    }
    
    var vaildationPhoneNumber: Bool {
        return input.phoneNumberTextField.count == 11
    }

    
    struct Input {
        var emailTextField = ""
        var passwordTextField: String = ""
        var passwordConfirmTextField: String = ""
        var nicknameTextField: String = ""
        var phoneNumberTextField: String = ""
        var introduceTextField: String = ""
        
    }
    
    struct Output {
        var isVaildEmail: Bool = false
        var isPasswordLongEnough: Bool = false
        var isPasswordComplexEnough: Bool = false
        var isValidPassword: Bool = false
        var isValidNickname: Bool = false
        var isValidPhoneNumber: Bool = false
        
        // 비밀번호 히든 체크
        var visibleStates: [PasswordField: Bool] = [
            .password: false,
            .confirm: false
        ]
        
        
    }
    
    func transform() {

        
    
    }
    
    
    private func toggleVisibility(for field: PasswordField) {
        output.visibleStates[field]?.toggle()
    }
 
    
}

// MARK: Action
extension CreateAccountViewModel {
    
    enum Action {
        case emailEditingCompleted
        case togglePasswordVisibility(type: PasswordField)
        case passwordEditingCompleted
        case passwordConfirmEditingCompleted
        case nickNameEditingCompleted
        case phoneNumberEditingCompleted
    }
    
    func action(_ action: Action) {
        switch action {
        case .emailEditingCompleted:
            output.isVaildEmail = validateEmail
        case .togglePasswordVisibility(let type):
            switch type {
            case .password:
                toggleVisibility(for: .password)
            case .confirm:
                toggleVisibility(for: .confirm)
            }
          
        case .passwordEditingCompleted:
            output.isPasswordLongEnough = validatePasswordLength
            output.isPasswordComplexEnough = validatePasswordCmplexEnough
        case .passwordConfirmEditingCompleted:
            output.isValidPassword = validatePassword
        case .nickNameEditingCompleted:
            output.isValidNickname = vaildationNicknameValid
        case .phoneNumberEditingCompleted:
            output.isValidPhoneNumber = vaildationPhoneNumber
        }
    }
    
    
}

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
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        transform()
    }
    
}

// MARK: Input/Output
extension CreateAccountViewModel {
    
    /// 이메일 유효성 검사
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
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: input.inputPassword)
    }
    
    /// 비밀번호 길이 검사
    var validatePasswordLength: Bool {
        return input.inputPassword.count > 7
    }
    
    var validatePassword: Bool {
        return input.inputPassword == input.inputPasswordConfirm
    }
    
    struct Input {
        var emailTextField = ""
        
        var inputPassword: String = ""
        var inputPasswordConfirm: String = ""
        
    }
    
    struct Output {
        var isVaildEmail: Bool = false
        var isPasswordLongEnough: Bool = false
        var isPasswordComplexEnough: Bool = false
        
        var isValidPassword: Bool = false
        
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
        }
    }
    
    
}

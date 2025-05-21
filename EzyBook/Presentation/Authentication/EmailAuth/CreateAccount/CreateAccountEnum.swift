//
//  CreateAccountEnum.swift
//  EzyBook
//
//  Created by youngkyun park on 5/15/25.
//

import Foundation

/// 패스워드 텍스트 필드
enum PasswordInputFieldType {
    case password        // 비밀번호
    case confirmPassword // 비밀번호 확인
    
    func toField() -> FocusField {
        switch self {
        case .password: return .password
        case .confirmPassword: return .confirmPassword
        }
    }
}

/// Focused Field
/// 회원가입에서 각 텍스트필드의 상태를 구분하기 위해서
enum FocusField: Hashable {
    case email, password, confirmPassword, nickname, phone
}

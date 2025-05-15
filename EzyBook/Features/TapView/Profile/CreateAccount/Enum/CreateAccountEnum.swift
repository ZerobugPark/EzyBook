//
//  CreateAccountEnum.swift
//  EzyBook
//
//  Created by youngkyun park on 5/15/25.
//

import Foundation

/// 패스워드 텍스트 필드
enum PasswordField {
    case password
    case confirm
}

/// enum
enum EmailValidationState {
    case empty
    case invalidFormat // 포맷확인
    case duplicated // 중복
    case available // 사용가능
    
    
}

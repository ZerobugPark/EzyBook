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
}


enum AppError {
    case error(code: Int, msg: String)
    
    var message: (title: String, msg: String) {
        switch self {
        case let .error(code, msg):
            let title = "Error: \(code)"
            return (title, msg)
        }
        
    }
}

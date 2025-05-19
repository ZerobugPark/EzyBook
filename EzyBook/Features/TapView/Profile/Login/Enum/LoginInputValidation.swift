//
//  LoginInputValidation.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import Foundation

enum LoginError {
    case emailInvalidFormat
    case passwordInvalidFormat
    case serverError(AppError)

    var title: String {
        switch self {
        case .serverError(let err): return err.message.title
        default: return "입력 오류"
        }
    }

    var message: String {
        switch self {
        case .emailInvalidFormat:
            return "유효하지 않은 이메일 형식입니다."
        case .passwordInvalidFormat:
            return "비밀번호는 8자리 이상이며, 특수문자, 영문자, 숫자를 포함해야 합니다."
        case .serverError(let err):
            return err.message.msg
        }
    }
}


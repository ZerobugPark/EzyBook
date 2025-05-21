//
//  LoginInputValidationError.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import Foundation

enum LoginFlowError {
    case emailInvalidFormat
    case passwordInvalidFormat
    case serverError(DisplayError)
    case kakaoLoginError(code: Int)
    case appleLoginError(code: Int)

    var title: String {
        switch self {
        case .serverError(let err):
            return err.message.title
        case .kakaoLoginError(let code):
            return  "Error: \(code)"
        case .appleLoginError(let code):
            return  "Error: \(code)"
        default:
            return "입력 오류"
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
        case .kakaoLoginError:
            return "카카오 로그인 오류"
        case .appleLoginError:
            return "애플 로그인 오류"
        }
    }
}


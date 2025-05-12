//
//  APIPath.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation

enum APIPath {
    
    /// 인증 관련 API
    enum Auth: String {
        case refersh = "/v1/auth/refresh"
    }
    
    /// 사용자 관련 API
    enum User: String {
        case validationEmail = "/v1/users/validation/email"
        case join = "/v1/users/join"
        case emailLogin = "/v1/users/login"
        case kakaoLogin = "/v1/users/login/kakao"
        case appleLogin = "/v1/users/login/apple"
        case profile = "/v1/users/me/profile"
        
    }
}

//
//  UserEndPoint.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation

enum UserEndPoint: APIEndPoint {
    
    case emailValidation
    case join
    case emailLogin
    case kakaoLogin
    case appleLogin
    case profileLookUp   // 조회
    case profileModify
    case deviceTokenUpdate
    case profileImageUpload
    case searchUser
    
    
    
    var path: String {
        switch self {
        case .emailValidation:
            return "/v1/users/validation/email"
        case .join:
            return "/v1/users/join"
        case .emailLogin:
            return "/v1/users/login"
        case .kakaoLogin:
            return "/v1/users/login/kakao"
        case .appleLogin:
            return "/v1/users/login/apple"
        case .profileLookUp, .profileModify:
            return "/v1/users/me/profile"
        case .deviceTokenUpdate:
            return "/v1/users/me/deviceToken"
        case .profileImageUpload:
            return "/v1/users/me/profile/image"
        case .searchUser:
            return "/v1/users/search"
        }
    }

}

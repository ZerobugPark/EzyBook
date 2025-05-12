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
    case profile
    
    var path: String {
        switch self {
        case .emailValidation:
            return APIPath.User.emailValidation.rawValue
        case .join:
            return APIPath.User.join.rawValue
        case .emailLogin:
            return APIPath.User.emailLogin.rawValue
        case .kakaoLogin:
            return APIPath.User.kakaoLogin.rawValue
        case .appleLogin:
            return APIPath.User.appleLogin.rawValue
        case .profile:
            return APIPath.User.profile.rawValue
        }
    }
    
    
}

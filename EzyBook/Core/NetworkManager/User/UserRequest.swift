//
//  UserRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation
import Alamofire

enum UserRequest: PostRouter {
    
    case validationEmail
    case join
    case emailLogin
    case kakaoLogin
    case appleLogin
    case profile
    
    
    var endpoint: URL {
        switch self {
        case .validationEmail:
            UserEndPoint.validationEmail.requestURL
        case .join:
            UserEndPoint.join.requestURL
        case .emailLogin:
            UserEndPoint.emailLogin.requestURL
        case .kakaoLogin:
            UserEndPoint.kakaoLogin.requestURL
        case .appleLogin:
            UserEndPoint.appleLogin.requestURL
        case .profile:
            UserEndPoint.profile.requestURL
        }
    }
    
    
    var method: HTTPMethod {
            switch self {
            case .validationEmail,
                 .join,
                 .emailLogin,
                 .kakaoLogin,
                 .appleLogin:
                return .post
            case .profile:
                return .get
            }
        }
    

}

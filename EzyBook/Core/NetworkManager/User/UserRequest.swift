//
//  UserRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation
import Alamofire

enum UserRequest: PostRouter {
    
    case emailValidation
    case join
    case emailLogin
    case kakaoLogin
    case appleLogin
    case profile
    
    
    var endpoint: URL? {
        switch self {
        case .emailValidation:
            UserEndPoint.emailValidation.requestURL
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
            case .emailValidation,
                 .join,
                 .emailLogin,
                 .kakaoLogin,
                 .appleLogin:
                return .post
            case .profile:
                return .get
            }
        }
    
    var requestBody: Encodable? {
         switch self {
         case .emailValidation(let request):
             return request
         case .join(let request):
             return request
         case .emailLogin(let request):
             return request
         case .kakaoLogin(let request):
             return request
         case .appleLogin(let request):
             return request
         case .profileLookup:
             return nil
         }
}

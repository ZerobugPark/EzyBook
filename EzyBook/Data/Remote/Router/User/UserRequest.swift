//
//  UserRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation
import Alamofire

enum UserRequest: PostRouter {
    
    case emailValidation(body: EmailValidationRequestDTO)
    case join(body: JoinRequestDTO)
    case emailLogin(body: EmailLoginRequestDTO)
    case kakaoLogin(body: KakaoLoginRequestDTO)
    case appleLogin(body: AppleLoginRequestDTO)
    case profileCheck
    
    
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
        case .profileCheck:
            UserEndPoint.profileCheck.requestURL
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
        case .profileCheck:
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
        case .profileCheck: //이거 따로 안빼도 되나? Post 전용인데?..
            return nil
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .emailValidation, .join, .emailLogin, .kakaoLogin, .appleLogin, .profileCheck:
            return [
                "SeSACKey": APIConstants.apiKey,
                "Content-Type": "application/json"
            ]
            
        }
    }
    
}

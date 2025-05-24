//
//  UserPostRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation
import Alamofire

enum UserPostRequest: PostRouter {
    
    case emailValidation(body: EmailValidationRequestDTO)
    case join(body: JoinRequestDTO)
    case emailLogin(body: EmailLoginRequestDTO)
    case kakaoLogin(body: KakaoLoginRequestDTO)
    case appleLogin(body: AppleLoginRequestDTO)
    
    
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
        }
    }
    
    
    var method: HTTPMethod {
        .post
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
        }
    }
    
    var headers: HTTPHeaders {
        return [
            "SeSACKey": APIConstants.apiKey,
            "Content-Type": "application/json"
        ]
        
    }
    
}

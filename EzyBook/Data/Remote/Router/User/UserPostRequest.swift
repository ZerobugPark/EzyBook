//
//  UserPostRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import SwiftUI
import Alamofire

enum UserPostRequest: PostRouter {
   
    //TODO: 프로필 이미지 업로드는 따로 만들어야 할듯
    
    case emailValidation(body: EmailValidationRequestDTO)
    case join(body: JoinRequestDTO)
    case emailLogin(body: EmailLoginRequestDTO)
    case kakaoLogin(body: KakaoLoginRequestDTO)
    case appleLogin(body: AppleLoginRequestDTO)
    case profileImageUpload(image: UIImage)
    
    var requiresAuth: Bool {
        false
    }
    
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
        case .profileImageUpload:
            UserEndPoint.profileImageUpload.requestURL
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
        case .profileImageUpload:
            return nil
        }
    }
    
    var headers: HTTPHeaders {
        [
            "SeSACKey": APIConstants.apiKey
        ]
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        switch self {
        case .profileImageUpload(let image):
            return { form in
                if let data = image.compressedJPEGData(maxSizeInBytes: 1_000_000) {
                    form.append(data,
                                withName: "profile",
                                fileName: "profile.jpg",
                                mimeType: "image/jpeg")
                }
            }
        default:
            return nil
        }
    }
}

//
//  UserPostRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import SwiftUI
import Alamofire

enum UserPostRequest: PostRouter {
    
    case emailValidation(body: EmailValidationRequestDTO)
    case join(body: JoinRequestDTO)
    case emailLogin(body: EmailLoginRequestDTO)
    case kakaoLogin(body: KakaoLoginRequestDTO)
    case appleLogin(body: AppleLoginRequestDTO)
    case profileImageUpload(image: UIImage)
    case profileModify(body: ProfileModifyRequestDTO)
    
    var requiresAuth: Bool {
        switch self {
        case .profileModify:
            return true
        default:
            return false
        }
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
        case .profileModify:
            UserEndPoint.profileModify.requestURL
        }
    }
    
    
    var method: HTTPMethod {
        switch self {
        case .profileModify:
                .put
        default:
                .post
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
        case .profileImageUpload:
            return nil
        case .profileModify(let request):
            return request
        }
    }
    
    var headers: HTTPHeaders {
        [
            "SeSACKey": APIConstants.apiKey
        ]
    }
    
    var parameters: Parameters? {
        switch self {
        case .profileModify(let param):
            let result: [String: Any?] = [
                "nick": param.nick,
                "profileImage": param.profileImage,
                "phoneNum": param.phoneNum,
                "introduction": param.introduction
            ]
            let filtered = result.compactMapValues { $0 } // 옵셔널 제거
            return filtered.isEmpty ? nil : filtered as Parameters // 업캐스팅
        default:
            return nil
            
        }
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


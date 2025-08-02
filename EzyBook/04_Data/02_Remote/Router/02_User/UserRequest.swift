//
//  UserRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import SwiftUI
import Alamofire

// MARK: Get
enum UserRequest {
    
    
    enum Get: GetRouter {
        
        case profileLookUp
        case searchUser(nick: String)
        
        var requiresAuth: Bool {
            true
        }
        
        var endpoint: URL? {
            switch self {
            case .profileLookUp:
                UserEndPoint.profileLookUp.requestURL
            case .searchUser:
                UserEndPoint.searchUser.requestURL
            }
        }
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
        }
        
        /// 쿼리중 ? 뒤에 오는것들
        var parameters: Parameters? {
            switch self {
            case .searchUser(let nick):
                return ["nick": nick]
            default:
                return nil
            }
        }
        
    }

    
}

// MARK: Post
extension UserRequest {
    
    enum Post: PostRouter {
        
        case emailValidation(body: EmailValidationRequestDTO)
        case join(body: JoinRequestDTO)
        case emailLogin(body: EmailLoginRequestDTO)
        case kakaoLogin(body: KakaoLoginRequestDTO)
        case appleLogin(body: AppleLoginRequestDTO)
        
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
            }
        }
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
        }
        

    }
}


// MARK: Put
extension UserRequest {
    
    enum Put: PutRouter {
        
        case profileModify(body: ProfileModifyRequestDTO)
        
        var requiresAuth: Bool {
            return true
        }
        
        var endpoint: URL? {
            switch self {
            case .profileModify:
                UserEndPoint.profileModify.requestURL
            }
        }
        
        var requestBody: Encodable? {
            switch self {
            case .profileModify(let body):
                return body
            }
        }
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
        }
        
//        var parameters: Parameters? {
//            switch self {
//            case .profileModify(let param):
//                let result: [String: Any?] = [
//                    "nick": param.nick,
//                    "profileImage": param.profileImage,
//                    "phoneNum": param.phoneNum,
//                    "introduction": param.introduction
//                ]
//                let filtered = result.compactMapValues { $0 } // 옵셔널 제거
//                return filtered.isEmpty ? nil : filtered as Parameters // 업캐스팅
//                
//            }
//        }
        
    }
    
}

// MARK: MultiPart
extension UserRequest {
    
    enum Multipart: MultipartRouter {
       
        case profileImageUpload(image: UIImage)
         
        var requiresAuth: Bool {
            return true
        }
        
        var endpoint: URL? {
            switch self {
            case .profileImageUpload:
                return UserEndPoint.profileImageUpload.requestURL
            }
        }
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey,
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
            }
        }
        
    }
}

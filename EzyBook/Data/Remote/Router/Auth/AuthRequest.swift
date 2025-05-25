//
//  AuthRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import Foundation
import Alamofire

enum AuthRequest: GetRouter {
    
    case refresh(accessToken: String, refreshToken: String)
    
    /// Auth를 안쓰긴 하지만, asURLRequset에서 헤더값을 강제로 붙이고 있기 때문에, true을 사용해서 헤더 추가 방지
    ///  인터셉터를 안쓰기 때문에 문제는 없음
    var requiresAuth: Bool {
        true }
    
    var endpoint: URL? {
        switch self {
        case .refresh:
            AuthEndPoint.refresh.requestURL
        }
    }
    
    
    var method: HTTPMethod {
        switch self {
        case .refresh:
            return .get
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case let .refresh(accessToken, refreshToken):
            return [
                "SeSACKey": APIConstants.apiKey,
                "RefreshToken": refreshToken,
                "Authorization": accessToken
            ]
            
        }
    }
    
}


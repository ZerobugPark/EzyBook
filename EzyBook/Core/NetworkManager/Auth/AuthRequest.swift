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


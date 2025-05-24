//
//  UserGetRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 5/24/25.
//

import Foundation
import Alamofire

enum UserGetRequest: GetRouter {
    
    case profileLookUp(accessToken: String)
    
    
    var endpoint: URL? {
        switch self {
        case .profileLookUp:
            UserEndPoint.profileLookUp.requestURL
        }
    }
    
    
    var method: HTTPMethod {
        .get
    }
    
    var headers: HTTPHeaders {
        
        switch self {
        case .profileLookUp(let accessToken):
            return [
                "SeSACKey": APIConstants.apiKey,
                "Authorization": accessToken
            ]
        }

    }
    
}

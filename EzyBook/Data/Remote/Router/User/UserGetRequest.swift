//
//  UserGetRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 5/24/25.
//

import Foundation
import Alamofire

enum UserGetRequest: GetRouter {
    
    case profileLookUp
    case searchUser(id: String)
    
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
    
    var method: HTTPMethod {
        .get
    }
    
    var headers: HTTPHeaders {
        [
            "SeSACKey": APIConstants.apiKey
        ]
    }
    
    var parameters: Parameters? {
        switch self {
        case .searchUser(let id):
            return ["nick": id]
        default:
            return nil
        }
    }
    

}

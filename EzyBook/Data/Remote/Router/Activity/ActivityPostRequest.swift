//
//  ActivityPostRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 5/31/25.
//

import Foundation
import Alamofire

enum ActivityPostRequest: PostRouter {
   
    case activityKeep(id: String, param: ActivityKeepRequestDTO)
 
    var requiresAuth: Bool {
        true
    }
    
    var endpoint: URL? {
        switch self {
        case .activityKeep(let id, _):
            ActivityEndPoint.activityKeep(id: id).requestURL
        }
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var requestBody: Encodable? {
        switch self {
        case .activityKeep(_, let param):
            return param
        }
    }
    
    var headers: HTTPHeaders {
        [
            "SeSACKey": APIConstants.apiKey
        ]
        
    }
    
}

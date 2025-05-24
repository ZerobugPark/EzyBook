//
//  ActivityRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 5/24/25.
//

import Foundation
import Alamofire

enum ActivityRequest: GetRouter {
    
    case activityFiles(accessToken: String)
    case activityDetail(accessToken: String, id: String)
    case newActivities(accessToken: String)
    
    var endpoint: URL? {
        switch self {
        case .activityFiles:
            ActivityEndPoint.activityList.requestURL
        case .activityDetail(_, let id):
            ActivityEndPoint.activityDetail(id: id).requestURL
        case .newActivities:
            ActivityEndPoint.newActivities.requestURL
        }
    }
    
    
    var method: HTTPMethod {
        switch self {
        case .activityFiles, .activityDetail, .newActivities:
            return .get
        }
    }
    
    var headers: HTTPHeaders {
        switch self {
        case .activityFiles(let accessToken),
                .activityDetail( let accessToken, _),
                .newActivities(let accessToken):
            return [
                "Authorization": accessToken,
                "SeSACKey": APIConstants.apiKey
            ]
            
        }
    }
    
}

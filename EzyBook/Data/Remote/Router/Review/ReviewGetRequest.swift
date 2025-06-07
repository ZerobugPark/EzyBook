//
//  ReviewGetRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 6/7/25.
//

import Foundation
import Alamofire

enum ReviewGetRequest: GetRouter {
    
    case reviewList(id: String)
    case reviewDetail(id: String, reviewID: String)
    case reviewRatingList(id: String)
    
    var requiresAuth: Bool {
        true
    }
    
    var endpoint: URL? {
        switch self {
        case .reviewList(let id):
            return ReviewEndPoint.reviewList(id: id).requestURL
        case .reviewDetail(let id, let reviewID):
            return ReviewEndPoint.reviewDelete(id: id, reviewID: reviewID).requestURL
        case .reviewRatingList(let id):
            return ReviewEndPoint.reviewRatingList(id: id).requestURL
        }
    }
    
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: HTTPHeaders {
        [
            "SeSACKey": APIConstants.apiKey
        ]
        
    }

}

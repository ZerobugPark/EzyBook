//
//  BannerRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 7/20/25.
//

import Foundation
import Alamofire

// MARK:  Get
enum BannerRequest {
    
    enum Get: GetRouter {
        case banner
        
        var requiresAuth: Bool {
            true
        }
        
        var endpoint: URL? {
            switch self {
            case .banner:
                BannerEndPoint.banner.requestURL
            }
        }
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
            
        }
    
    }
}

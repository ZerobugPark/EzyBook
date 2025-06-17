//
//  OrderRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 6/12/25.
//

import Foundation
import Alamofire

// MARK:  Get
enum OrderRequest {
    
    enum Get: GetRouter {
        case order
        
        var requiresAuth: Bool {
            true
        }
        
        var endpoint: URL? {
            switch self {
            case .order:
                OrderEndPoint.order.requestURL
            }
        }
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
            
        }
    
    }
}


// MARK:  Post
extension OrderRequest {
    
    enum Post: PostRouter {
        case order(dto: OrderCreateRequestDTO)
     
        var requiresAuth: Bool {
            true
        }
        
        var endpoint: URL? {
            switch self {
            case .order:
                OrderEndPoint.order.requestURL
            }
        }
        
        var requestBody: Encodable? {
            switch self {
            case .order(let request):
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


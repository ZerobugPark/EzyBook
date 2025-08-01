//
//  PaymentRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 6/17/25.
//

import Foundation
import Alamofire

// MARK:  Get
enum PaymentRequest {
    
    enum Get: GetRouter {
        case paymentLookUp(code: String)
        
        var requiresAuth: Bool {
            true
        }
        
        var endpoint: URL? {
            switch self {
            case .paymentLookUp(let code):
                PaymentEndPoint.paymentLookUp(code: code).requestURL
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
extension PaymentRequest {
    
    enum Post: PostRouter {
        case vaildation(dto: PaymentValidationDTO)
     
        var requiresAuth: Bool {
            true
        }
        
        var endpoint: URL? {
            switch self {
            case .vaildation:
                PaymentEndPoint.vaildation.requestURL
            }
        }
        
        var requestBody: Encodable? {
            switch self {
            case .vaildation(let request):
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



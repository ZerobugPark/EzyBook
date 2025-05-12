//
//  PostRouter.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation

import Alamofire

/// Post 전용
protocol PostRouter: NetworkRouter {
    var requestBody: Encodable? { get }
    var encoder: RequestEncoder { get }
}

extension PostRouter {
    var encoder: RequestEncoder {
        return URLQueryEncoder()
    }
    
    func asURLRequest() throws -> URLRequest {
        var request = try baseURLRequest()
        
        // POST 요청 특화 처리 (body)
        if let body = requestBody {
            request = try JSONParameterEncoder.default
                .encode(body, into: request)
        }
        
        return request
    }
}


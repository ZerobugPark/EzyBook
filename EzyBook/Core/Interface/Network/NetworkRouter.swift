//
//  NetworkRouter.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation

import Alamofire



protocol NetworkRouter: URLRequestConvertible {
    var endpoint: URL? { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
}

extension NetworkRouter {
    
    var parameters: Parameters? {
        return nil
    }
    
    /// Helper Function (프로토콜 추가할 필요가 없음)
    func makeURLRequest() throws -> URLRequest {
        guard let url = endpoint else {
            throw APIError.missingEndpoint
        }
        var request = URLRequest(url: url)
        request.method = method
        request.headers = APIConstants.commonHeaders
        return request
    }
    
    // URLRequestConvertible 프로토콜 필수 사항
    func asURLRequest() throws -> URLRequest {
        try makeURLRequest()
    }
    
}



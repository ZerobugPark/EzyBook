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
    
    func baseURLRequest() throws -> URLRequest {
        guard let url = endpoint else {
            throw APIError.emailUnavailable
        }
        var request = URLRequest(url: url)
        request.method = method
        request.headers = APIConstants.commonHeaders
        return request
    }
    

    
}



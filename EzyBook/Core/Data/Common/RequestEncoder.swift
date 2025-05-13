//
//  RequestEncoder.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation

import Alamofire

/// URL 쿼리 인코더 구현
struct URLQueryEncoder {
    func encode(request: URLRequest, with requestBody: Encodable?) throws -> URLRequest {
        
        guard let body = requestBody else {
            throw APIError.missingRequestBody
        }
        
        return try JSONParameterEncoder.default.encode(body, into: request)
    }
}

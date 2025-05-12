//
//  RequestEncoder.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation

import Alamofire

/// 단일 책임 분리를 위한 Encoder
protocol RequestEncoder {
    func encode(request: URLRequest, with parameters: Encodable?) throws -> URLRequest
}

// URL 쿼리 인코더 구현
struct URLQueryEncoder: RequestEncoder {
    func encode(request: URLRequest, with requestBody: Encodable?) throws -> URLRequest {
        
        guard let body = requestBody else {
            throw APIError.expiredRefreshToken
        }
        
        return try JSONParameterEncoder.default.encode(body, into: request)
    }
}

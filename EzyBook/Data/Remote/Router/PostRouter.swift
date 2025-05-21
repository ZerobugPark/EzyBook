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
    var encoder: URLQueryEncoder { get }
    func encodeBody(for request: URLRequest) throws -> URLRequest
}

extension PostRouter {
    var encoder: URLQueryEncoder {
        return URLQueryEncoder()
    }
    
    /// POST 요청 특화 처리 (body)
    func encodeBody(for request: URLRequest) throws -> URLRequest {
        guard let body = requestBody else {
            throw APIError(localErrorType: .missingRequestBody)
        }
        return try encoder.encode(request: request, with: body)
    }
    
    /// Post 전용으로 재정의
    func asURLRequest() throws -> URLRequest {
        var request = try makeURLRequest()
        
        request = try encodeBody(for: request)
        
        // body 체크
//        if let httpBody = request.httpBody,
//           let bodyString = String(data: httpBody, encoding: .utf8) {
//            print("Body JSON: \(bodyString)")
//        }
        
        return request
    }
}


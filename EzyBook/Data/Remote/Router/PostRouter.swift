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
    //var encoder: URLQueryEncoder { get }
    var bodyEncoder: JSONEncoder { get }
    func encodeBody(for request: URLRequest) throws -> URLRequest
}

extension PostRouter {
    
    var bodyEncoder: JSONEncoder {
        JSONEncoder()
    }
    
    /// POST 요청 특화 처리 (body)
    func encodeBody(for request: URLRequest) throws -> URLRequest {
        guard let body = requestBody else {
            throw APIError(localErrorType: .missingRequestBody)
        }

        var request = request
        request.httpBody = try bodyEncoder.encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return request//try encoder.encode(request: request, with: body)
    }
    
    /// Post 전용으로 재정의
    func asURLRequest() throws -> URLRequest {
        var request = try makeURLRequest()
        
        request = try encodeBody(for: request)
        
        /// 헤더 여부 판단
        /// forHTTPHeaderField는 URLRequest 메서드로 Alamofire는 별개
        if !requiresAuth {
            request.setValue("true", forHTTPHeaderField: "No-Auth")
        }
        
        // body 체크
//        if let httpBody = request.httpBody,
//           let bodyString = String(data: httpBody, encoding: .utf8) {
//            print("Body JSON: \(bodyString)")
//        }
        
        return request
    }
}


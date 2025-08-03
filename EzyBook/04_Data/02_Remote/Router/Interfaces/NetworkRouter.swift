//
//  NetworkRouter.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation
import Alamofire

/// 모든 라우터가 갖춰야할 최소 조건
protocol NetworkRouter: URLRequestConvertible {
    var endpoint: URL? { get }
    var parameterEncoder: ParameterEncoding { get }
    var requiresAuth: Bool { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: HTTPHeaders { get }
}

extension NetworkRouter {
    
    var parameters: Parameters? {
        nil
    }
    
    
    var parameterEncoder: ParameterEncoding {
        URLEncoding.default
    }
    
    /// Helper Function (프로토콜 추가할 필요가 없음)
    /// 요청의 기본 형태 (URL, method, headers까지)
    func makeURLRequest() throws -> URLRequest {
        guard let url = endpoint else {
            throw APIError(localErrorType: .missingEndpoint)
        }
        var request = URLRequest(url: url)
        request.method = method
        request.headers = headers
        return request
    }
    
    /// URLRequestConvertible 프로토콜 필수 사항
    func asURLRequest() throws -> URLRequest {
        var request = try makeURLRequest()
        
        /// 헤더 여부 판단
        /// forHTTPHeaderField는 URLRequest 메서드로 Alamofire는 별개
        if !requiresAuth {
            request.setValue("true", forHTTPHeaderField: "No-Auth")
        }
    
        return try parameterEncoder.encode(request, with: parameters)
    }
    
}



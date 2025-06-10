//
//  BodyRequestRouter.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import Foundation

protocol BodyRequestRouter: BaseRouter {
    var requestBody: Encodable? { get }
    var bodyEncoder: JSONEncoder { get }
}

extension BodyRequestRouter {
    
    var bodyEncoder: JSONEncoder {
        JSONEncoder()
    }

    func asURLRequest() throws -> URLRequest {
        var request = try makeURLRequest()

        if let body = requestBody {
            request.httpBody = try bodyEncoder.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        // 공통 헤더 처리
        request.headers = headers

        if !requiresAuth {
            request.setValue("true", forHTTPHeaderField: "No-Auth")
        }

        return request
    }
}


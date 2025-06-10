//
//  BaseRouter.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import Foundation
import Alamofire

protocol BaseRouter: NetworkRouter {
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get }
    var parameters: Parameters? { get }
}

extension BaseRouter {
    func asURLRequest() throws -> URLRequest {
        var request = try makeURLRequest()

        // 인자 인코딩 (기본은 URL 파라미터)
        request = try URLEncoding.default.encode(request, with: parameters)

        request.headers = headers
    
        if !requiresAuth {
            request.setValue("true", forHTTPHeaderField: "No-Auth")
        }

        return request
    }
}

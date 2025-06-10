//
//  Routers.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import Foundation
import Alamofire

protocol PostRouter: BodyRequestRouter { }
extension PostRouter {
    var method: HTTPMethod { .post }
}

protocol PutRouter: BodyRequestRouter { }
extension PutRouter {
    var method: HTTPMethod { .put }
}

protocol GetRouter: BaseRouter { }
extension GetRouter {
    var method: HTTPMethod { .get }
}

protocol MultipartRouter: NetworkRouter {
    var multipartFormData: ((MultipartFormData) -> Void)? { get }
}

extension MultipartRouter {
    var method: HTTPMethod { .post } // 대부분 업로드는 POST

    func asURLRequest() throws -> URLRequest {
        var request = try makeURLRequest()
        if !requiresAuth {
            request.setValue("true", forHTTPHeaderField: "No-Auth")
        }
        return request
    }
}

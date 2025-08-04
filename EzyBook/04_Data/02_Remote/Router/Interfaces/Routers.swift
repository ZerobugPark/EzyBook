//
//  Routers.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import Foundation
import Alamofire


protocol GetRouter: BaseRouter { }
extension GetRouter {
    var method: HTTPMethod { .get }
}

protocol PostRouter: BodyRequestRouter { }
extension PostRouter {
    var method: HTTPMethod { .post }
}

protocol PutRouter: BodyRequestRouter { }
extension PutRouter {
    var method: HTTPMethod { .put }
}

protocol DeleteRouter: BaseRouter { }
extension DeleteRouter {
    var method: HTTPMethod { .delete }
}

protocol MultipartRouter: NetworkRouter {
    var multipartFormData: ((MultipartFormData) -> Void)? { get }
    /// 멀티파트 이미지가 안올라 갔을 때 확인하기 위한 파라미터
    var isEffectivelyEmpty: Bool { get }
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

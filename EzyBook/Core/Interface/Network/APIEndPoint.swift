//
//  APIEndPoint.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation

protocol APIEndPoint {
    var path: String { get }
}

extension APIEndPoint {
    // 기본 baseURL 제공
    var baseURL: String {
        return APIConstants.baseURL
    }
    
    // requestURL은 baseURL과 path를 합친 URL로 기본 구현
    var requestURL: URL {
        return URL(string: baseURL + path)!
    }
}

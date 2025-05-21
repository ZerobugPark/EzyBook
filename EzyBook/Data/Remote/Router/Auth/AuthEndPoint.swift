//
//  AuthEndPoint.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation

enum AuthEndPoint: APIEndPoint {
    
    case refresh
    
    var path: String {
        switch self {
        case .refresh:
            return APIPath.Auth.refersh.rawValue
        }
    }
    
}

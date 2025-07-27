//
//  DisplayError.swift
//  EzyBook
//
//  Created by youngkyun park on 5/20/25.
//

import Foundation

enum DisplayError {
    case error(code: Int, msg: String)
    case sucess(msg: String)
    
    var code: Int? {
        switch self {
        case let .error(code, _):
            return code
        case .sucess:
            return nil
        }
    }
    
    
    var message: (title: String, msg: String) {
        switch self {
        case let .error(code, msg):
            let title = "Error: \(code)"
            return (title, msg)
        case let .sucess(msg):
            let title = "Success"
            return (title, msg)
        }
        
    }
}

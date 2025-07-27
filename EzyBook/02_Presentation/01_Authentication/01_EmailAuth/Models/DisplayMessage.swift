//
//  DisplayError.swift
//  EzyBook
//
//  Created by youngkyun park on 5/20/25.
//

import Foundation

enum DisplayMessage {
    case error(code: Int, msg: String)
    case success(msg: String)
    
    var code: Int? {
        switch self {
        case let .error(code, _):
            return code
        case .success:
            return nil
        }
    }
    
    var title: String {
        switch self {
        case let .error(code, _):
            return "Error: \(code)"
        case .success:
            return "Success"
        }
    }
    
    var message: String {
        switch self {
        case let .error(_, msg), let .success(msg):
            return msg
        }
    }
    
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}

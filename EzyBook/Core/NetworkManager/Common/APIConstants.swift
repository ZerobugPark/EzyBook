//
//  APIConstants.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation
import Alamofire

enum APIConstants {
    
    static var apiKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            fatalError("API_KEY not found in Info.plist")
        }
        return apiKey
    }

    static var baseURL: String {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else {
            fatalError("API_KEY not found in Info.plist")
        }
        return baseURL
    }
    
        
    static let commonHeaders: HTTPHeaders = [
        "SeSACKey": apiKey,
        "Content-Type": "application/json"
    ]
}

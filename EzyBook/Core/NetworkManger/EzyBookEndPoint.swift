//
//  EzyBookEndPoint.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation


enum EzyBookEndPoint {
    
    case search
    
    private var baseURL: String {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String else {
            fatalError("API_KEY not found in Info.plist")
        }
        return baseURL
    }
    
    
    
    //
    //    var path: String {
    //
    //    }
    //    var fullURL: String {
    //
    //    }
}

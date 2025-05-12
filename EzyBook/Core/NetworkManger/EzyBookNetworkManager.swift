//
//  EzyBookNetworkManager.swift
//  EzyBook
//
//  Created by youngkyun park on 5/12/25.
//

import Foundation



private var apiKey: String {
    guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
        fatalError("API_KEY not found in Info.plist")
    }
    return apiKey
}

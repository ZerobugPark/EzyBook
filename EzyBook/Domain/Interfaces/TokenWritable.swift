//
//  TokenWritable.swift
//  EzyBook
//
//  Created by youngkyun park on 5/24/25.
//

import Foundation

protocol TokenWritable {
    func saveToken(key: String, value: String) -> Bool
    func saveTokens(accessToken: String, refreshToken: String) -> Bool
}


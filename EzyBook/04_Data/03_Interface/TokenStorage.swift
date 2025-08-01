//
//  TokenStorage.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import Foundation

protocol TokenStorage: Sendable {
    func saveToken(key: String, value token: String) -> Bool
    func loadToken(key: String) -> String?
    func deleteToken(key: String) -> Bool
}

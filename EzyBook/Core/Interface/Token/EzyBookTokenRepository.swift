//
//  EzyBookTokenRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import Foundation

protocol EzyBookTokenRepository {
    func saveToken(key: String, value: String) -> Bool
    func loadToken(key: String) -> String?
    func deleteToken(key: String) -> Bool
}

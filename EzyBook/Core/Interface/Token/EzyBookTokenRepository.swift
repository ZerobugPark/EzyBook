//
//  EzyBookTokenRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import Foundation

protocol EzyBookTokenRepository {
    func save(key: String, value: String) -> Bool
    func loadRefreshToken(key: String) -> String?
    func deleteToken(key: String) -> Bool
}

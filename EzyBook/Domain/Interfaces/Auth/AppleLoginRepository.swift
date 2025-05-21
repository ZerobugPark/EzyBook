//
//  AppleLoginRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import Foundation

protocol AppleLoginRepository {
    func requestAppleLogin(_ token: String, _ name: String?) async throws -> LoginEntity
}

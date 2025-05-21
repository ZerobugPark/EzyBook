//
//  AppleLoginRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import Foundation

protocol AppleLoginRepository {
    func loingWithApple(_ token: String) async throws -> LoginEntity
}

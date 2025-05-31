//
//  EmailLoginRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import Foundation

protocol EmailLoginRepository {
    func requestEmailLogin(_ router: UserPostRequest) async throws -> LoginEntity
}

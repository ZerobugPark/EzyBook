//
//  EmailLoginRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import Foundation

protocol EmailLoginRepository {
    func emailLogin(_ router: UserRequest) async throws -> LoginEntity
}

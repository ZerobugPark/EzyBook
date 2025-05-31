//
//  ActivityDetailRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/27/25.
//

import Foundation

protocol ActivityDetailRepository {
    func requestActivityDetail(_ router: ActivityGetRequest) async throws -> ActivityDetailEntity
}

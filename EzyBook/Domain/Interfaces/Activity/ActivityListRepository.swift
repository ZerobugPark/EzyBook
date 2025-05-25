//
//  ActivityListRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import Foundation

protocol ActivityListRepository {
    func requestActivityList(_ router: ActivityRequest) async throws -> ActivitySummaryListEntity
}

//
//  ActivityListRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import Foundation

/// 액티비티 목록 조회
protocol ActivityListRepository {
    func requestActivityList(_ router: ActivityGetRequest) async throws -> ActivitySummaryListEntity
}

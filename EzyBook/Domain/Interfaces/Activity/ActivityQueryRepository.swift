//
//  ActivityNewListRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import Foundation

/// 신규 액티비티 및 액티비티 검색 공용
protocol ActivityQueryRepository {
    func requestActivityNewList(_ router: ActivityGetRequest) async throws -> [ActivitySummaryEntity]
}

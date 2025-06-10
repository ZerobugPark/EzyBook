//
//  ActivityRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import Foundation

/// 신규 액티비티 및 액티비티 검색 공용
protocol ActivityQueryRepository {
    func requestActivityNewList(_ router: ActivityRequest.Get) async throws -> [ActivitySummaryEntity]
}

/// 액티비티 목록 조회
protocol ActivityListRepository {
    func requestActivityList(_ router: ActivityRequest.Get) async throws -> ActivitySummaryListEntity
}


protocol ActivityKeepCommandRepository {
    func requestToggleKeep(_ router: ActivityRequest.Post) async throws -> ActivityKeepEntity
}


protocol ActivityDetailRepository {
    func requestActivityDetail(_ router: ActivityRequest.Get) async throws -> ActivityDetailEntity
}

protocol ActivityKeepQueryRepository {
    
}

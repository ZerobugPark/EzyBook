//
//  ActivityRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import Foundation

/// 신규 액티비티
protocol ActivityNewListRepository {
    func requestActivityNewList(_ country: String?, _ category: String?) async throws -> [ActivitySummaryEntity]
}

/// 액티비티 목록 조회
protocol ActivityListRepository {
    func requestActivityList(_ country: String?, _ category: String?, _ limit: String, _ next: String?) async throws -> ActivitySummaryListEntity
}


/// 액티비티 검색
protocol ActivitySearchRepository {
    func requestActivitySearch(_ title: String) async throws -> [ActivitySummaryEntity]
}


/// 액태비비 좋아요
protocol ActivityKeepCommandRepository {
    func requestToggleKeep(_ id: String, _ stauts: Bool) async throws -> ActivityKeepEntity
}

/// 액티비티 상세 조회
protocol ActivityDetailRepository {
    func requestActivityDetail(_ id: String) async throws -> ActivityDetailEntity
}

protocol ActivityKeepQueryRepository {
    
}

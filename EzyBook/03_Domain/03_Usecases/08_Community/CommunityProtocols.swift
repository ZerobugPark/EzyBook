//
//  CommunityProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 8/2/25.
//

import Foundation

protocol PostSummaryPaginationUseCase {
    func execute(query: ActivityPostLookUpQuery) async throws -> PostSummaryPaginationEntity
}


protocol PostSearchUseCase {
    func execute(title: String) async throws -> [PostSummaryEntity]
}

// MARK: Realm
protocol WrittenActivityListUseCase {
    func execute() -> [String]
}

protocol WriteActivityUseCase {
    func execute(activityID: String)
}



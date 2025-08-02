//
//  03_ActivityPostRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 8/2/25.
//

import Foundation

protocol PostSummaryPaginationRepository {
    func requestActivityPost(query: ActivityPostLookUpQuery)  async throws -> PostSummaryPaginationEntity
}

protocol PostSearchRepository {
    func reqeustSearchPost(_ title: String) async throws -> [PostSummaryEntity]
}


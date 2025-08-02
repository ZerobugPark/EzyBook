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
    func excute(title: String) async throws -> [PostSummaryEntity]
}

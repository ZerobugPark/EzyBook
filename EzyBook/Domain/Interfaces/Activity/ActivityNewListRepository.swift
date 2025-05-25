//
//  ActivityNewListRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import Foundation

protocol ActivityNewListRepository {
    func requestActivityNewList(_ router: ActivityRequest) async throws -> [ActivitySummaryEntity]
}

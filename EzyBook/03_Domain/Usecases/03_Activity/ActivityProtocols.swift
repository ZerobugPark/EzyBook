//
//  ActivityProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 7/25/25.
//

import Foundation


protocol NewActivityListUseCase {
    func execute(country: String?, category: String?) async throws -> [ActivitySummaryEntity]
}

protocol ActivityListUseCase {
    func execute(country: String?, category: String?, limit: String, next: String?) async throws -> ActivitySummaryListEntity
}

protocol ActivityDetailUseCase {
    func execute(id: String) async throws -> ActivityDetailEntity
}

protocol ActivitySearchUseCase {
    func execute(title: String) async throws -> [ActivitySummaryEntity]
}


protocol ActivityKeepCommandUseCase {
    func execute(id: String, stauts: Bool) async throws -> ActivityKeepEntity
}


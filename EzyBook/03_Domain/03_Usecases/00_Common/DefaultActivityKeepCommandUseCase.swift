//
//  DefaultActivityKeepCommandUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/31/25.
//

import Foundation

final class DefaultActivityKeepCommandUseCase: ActivityKeepCommandUseCase {
    
    private let repo: ActivityKeepCommandRepository
    
    init(repo: ActivityKeepCommandRepository) {
        self.repo = repo
    }
    

}

extension DefaultActivityKeepCommandUseCase {
    func execute(id: String, stauts: Bool) async throws -> ActivityKeepEntity {
        try await repo.requestToggleKeep(id, stauts)
    }
}


final class DefaultActivityKeepListUseCase: ActivityKeepListUseCase {
    
    private let repo: ActivityKeepListRepository
    
    init(repo: ActivityKeepListRepository) {
        self.repo = repo
    }
    

}

extension DefaultActivityKeepListUseCase {
    func execute(next: String?, limit: String) async throws ->  ActivitySummaryListEntity {
        try await repo.request(next: next, limit: limit)
    }
}


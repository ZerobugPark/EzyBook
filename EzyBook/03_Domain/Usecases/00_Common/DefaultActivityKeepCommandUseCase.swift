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


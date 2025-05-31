//
//  DefaultActivityKeepCommandUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/31/25.
//

import Foundation

final class DefaultActivityKeepCommandUseCase {
    
    private let repo: ActivityKeepCommandRepository
    
    init(repo: ActivityKeepCommandRepository) {
        self.repo = repo
    }
    
    func execute(id: String, stauts: Bool) async throws -> ActivityKeepEntity {

        let dto = ActivityKeepRequestDTO(status: stauts)
        let router = ActivityPostRequest.activityKeep(id: id, param: dto)
        do {
            return try await repo.requestToggleKeep(router)
        } catch {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
    }
}


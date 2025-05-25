//
//  DefaultActivityListUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import Foundation

final class DefaultActivityListUseCase {

    private let repo: ActivityListRepository
    
    init(repo: ActivityListRepository) {
        self.repo = repo
    }
    
    
}

extension DefaultActivityListUseCase {
    
    func execute(requestDto: ActivitySummaryListRequestDTO,  completionHandler: @escaping (Result <ActivitySummaryListEntity, APIError>) -> Void) {

        let router = ActivityRequest.activityList(param: requestDto)
        
        Task {
            do {
                let data = try await repo.requestActivityList(router)
                
                await MainActor.run {
                    completionHandler(.success((data)))
                }
            } catch  {
                let resolvedError: APIError
                if let apiError = error as? APIError {
                    resolvedError = apiError
                } else {
                    resolvedError = .unknown
                }
                await MainActor.run {
                    completionHandler(.failure(resolvedError))
                }

            }
        }
    }
}

//
//  DefaultNewActivityListUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import Foundation

final class DefaultNewActivityListUseCase {

    private let repo: ActivityQueryRepository
    
    init(repo: ActivityQueryRepository) {
        self.repo = repo
    }
    
    
}


extension DefaultNewActivityListUseCase {
    
    func execute(country: String?, category: String?,  completionHandler: @escaping (Result <[ActivitySummaryEntity], APIError>) -> Void) {

        
        let requestDto = ActivityNewSummaryListRequestDTO(country: country, category: category)
        
        let router = ActivityRequest.newActivities(param: requestDto)
        
        Task {
            do {
                let data = try await repo.requestActivityNewList(router)
                
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

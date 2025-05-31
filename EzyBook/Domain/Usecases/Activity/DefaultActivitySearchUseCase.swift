//
//  DefaultActivitySearchUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import Foundation

final class DefaultActivitySearchUseCase {

    private let repo: ActivityQueryRepository
    
    init(repo: ActivityQueryRepository) {
        self.repo = repo
    }
    
    func execute(title: String,  completionHandler: @escaping (Result <[ActivitySummaryEntity], APIError>) -> Void) {

        
        let requestDto = ActivitySearchListRequestDTO(title: title)
        
        let router = ActivityGetRequest.serachActiviy(param: requestDto)
        
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


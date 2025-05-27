//
//  DefaultNewActivityListUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import Foundation
import Combine

final class DefaultNewActivityListUseCase {
    
    private let repo: ActivityQueryRepository
    
    init(repo: ActivityQueryRepository) {
        self.repo = repo
    }
    
    
}


extension DefaultNewActivityListUseCase {
//    
//    func executePulisher(country: String?, category: String?) -> AnyPublisher<[ActivitySummaryEntity], APIError> {
//        
//        let requestDto = ActivityNewSummaryListRequestDTO(country: country, category: category)
//        let router = ActivityRequest.newActivities(param: requestDto)
//        
//        return Future<[ActivitySummaryEntity], APIError> { [weak self] promise in
//            
//            guard let self = self else { return }
//            
//            Task {
//                do {
//                    let data = try await self.repo.requestActivityNewList(router)
//                    promise(.success(data))
//                
//                } catch  {
//                    let resolvedError: APIError
//                    if let apiError = error as? APIError {
//                        resolvedError = apiError
//                    } else {
//                        resolvedError = .unknown
//                    }
//                    promise(.failure(resolvedError))
//                    
//                }
//            }
//        }
//        .eraseToAnyPublisher() // 타입 숨기기
//        
//    }
    
    func execute(country: String?, category: String?) async throws -> [ActivitySummaryEntity] {
        let requestDto = ActivityNewSummaryListRequestDTO(country: country, category: category)
        let router = ActivityRequest.newActivities(param: requestDto)

        do {
            return try await repo.requestActivityNewList(router)
        } catch {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
    }
}

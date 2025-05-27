//
//  DefaultActivityListUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import Foundation
import Combine

final class DefaultActivityListUseCase {
    
    private let repo: ActivityListRepository
    
    init(repo: ActivityListRepository) {
        self.repo = repo
    }
    
    
}

extension DefaultActivityListUseCase {
    
    func execute(requestDto: ActivitySummaryListRequestDTO) async throws -> ActivitySummaryListEntity {
        
        let router = ActivityRequest.activityList(param: requestDto)
        
        do {
            /// await: 결과 대기
            /// try: 결과를 await할 때 오류 감지
            return try await self.repo.requestActivityList(router)
            
        } catch  {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
            
        }
    }
    
}




//    func executePulisher(requestDto: ActivitySummaryListRequestDTO) -> AnyPublisher<ActivitySummaryListEntity, APIError> {
//
//        let router = ActivityRequest.activityList(param: requestDto)
//
//        /// Future 아직 일어나지 않은 미래(곧 발생)
//        /// promise 값이 올거니까 promise라는 파라미터 명을 쓰는 듯
//        /// Future는 one-shot이다. 즉  promise에게 value나 error를 한번 보내고 나면 바로 finished
//        return Future<ActivitySummaryListEntity, APIError> { [weak self] promise in
//
//            guard let self = self else { return }
//
//            Task {
//                do {
//                    let data = try await self.repo.requestActivityList(router)
//                    promise(.success(data))
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
//        }.eraseToAnyPublisher()
//    }


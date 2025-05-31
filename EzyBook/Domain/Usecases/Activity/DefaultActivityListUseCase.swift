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
    
    func execute(requestDto: ActivitySummaryListRequestDTO) async throws -> ActivitySummaryListEntity {
        
        let router = ActivityGetRequest.activityList(param: requestDto)
        
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

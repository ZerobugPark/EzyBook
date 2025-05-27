//
//  DefaultActivityRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import Foundation

import Foundation

final class DefaultActivityRepository: ActivityListRepository, ActivityQueryRepository,  ActivityDetailRepository {
 
    

    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// 액티비티 목록 조회
    func requestActivityList(_ router: ActivityRequest) async throws -> ActivitySummaryListEntity {
        let data = try await networkService.fetchData(dto: ActivitySummaryListResponseDTO.self, router)
        return data.toEntity()
    }
    
    /// 신규 액티비티 목록 조회
    /// 액티비티 검색 결과
    func requestActivityNewList(_ router: ActivityRequest) async throws -> [ActivitySummaryEntity] {
        let data = try await networkService.fetchData(dto: ActivityListResponseDTO.self, router)
        return data.toEntity()
    }
    
    func requestActivityDetail(_ router: ActivityRequest) async throws -> ActivityDetailEntity {
        let data = try await networkService.fetchData(dto: ActivityDetailResponseDTO.self, router)
        
        return data.toEntity()
    }
    
}


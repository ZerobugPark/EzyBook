//
//  DefaultActivityRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import Foundation

final class DefaultActivityRepository: ActivityNewListRepository, ActivityListRepository, ActivitySearchRepository, ActivityDetailRepository  {

    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    

    /// 신규 액티비티 목록 조회
    func requestActivityNewList(_ country: String?, _ category: String?) async throws -> [ActivitySummaryEntity] {
        
        let dto = ActivityNewSummaryListRequestDTO(country: country, category: category)
        let router = ActivityRequest.Get.newActivities(param: dto)
        
        let data = try await networkService.fetchData(dto: ActivityListResponseDTO.self, router)
        return data.toEntity()
        
    }
    
    /// 액티비티 목록 조회
    func requestActivityList(_ country: String?, _ category: String?, _ limit: String, _ next: String?) async throws -> ActivitySummaryListEntity {
        
        let dto = ActivitySummaryListRequestDTO(country: country, category: category, limit: limit, next: next)
        
        let router = ActivityRequest.Get.activityList(param: dto)
        
        let data = try await networkService.fetchData(dto: ActivitySummaryListResponseDTO.self, router)
        return data.toEntity()
    }
    
    
    /// 액티비티 검색 결과
    func requestActivitySearch(_ title: String) async throws -> [ActivitySummaryEntity] {
        
        let dto = ActivitySearchListRequestDTO(title: title)
        let router = ActivityRequest.Get.serachActiviy(param: dto)
        
        let data = try await networkService.fetchData(dto: ActivityListResponseDTO.self, router)
        return data.toEntity()
    }
    
    
    /// 액티비티 상세조회

    func requestActivityDetail(_ id: String) async throws -> ActivityDetailEntity {
        
        let dto = ActivityDetailRequestDTO(activityId: id)
        
        let router = ActivityRequest.Get.activityDetail(param: dto)
        
        let data = try await networkService.fetchData(dto: ActivityDetailResponseDTO.self, router)
        
        return data.toEntity()
    }
}


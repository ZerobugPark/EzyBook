//
//  DefaultKeepStatusRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/31/25.
//

import Foundation


final class DefaultKeepStatusRepository: ActivityKeepCommandRepository,  ActivityKeepQueryRepository {
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// 킵 요청
    func requestToggleKeep(_ id: String, _ stauts: Bool) async throws -> ActivityKeepEntity {
        let dto = ActivityKeepRequestDTO(status: stauts)
        let router = ActivityRequest.Post.activityKeep(id: id, param: dto)
        
        let data = try await networkService.fetchData(dto: ActivityKeepResponseDTO.self, router)
        
        return data.toEntity()
        
    }
    
    
    //TODO: Keep list 조회
    
    
}


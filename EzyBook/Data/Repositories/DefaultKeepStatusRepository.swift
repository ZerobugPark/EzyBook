//
//  DefaultKeepStatusRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/31/25.
//

import Foundation


struct DefaultKeepStatusRepository: ActivityKeepCommandRepository,  ActivityKeepQueryRepository {
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// 킵 요청
    func requestToggleKeep(_ router: ActivityPostRequest) async throws -> ActivityKeepEntity  {
        
        let data = try await networkService.fetchData(dto: ActivityKeepResponseDTO.self, router)
        
        return data.toEntity()
        
    }
    
    //TODO: Keep list 조회
}


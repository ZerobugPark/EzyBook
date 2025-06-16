//
//  DefaultOrderRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/16/25.
//

import Foundation

struct DefaultOrderRepository: OrderCreateRepository {
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    /// 킵 요청
    func requestOrderCreate(_ router: OrderRequest.Post) async throws -> OrderCreateEntity  {
        
        let data = try await networkService.fetchData(dto: OrderCreateResponseDTO.self, router)
        
        return data.toEntity()
        
    }
    
    //TODO: Keep list 조회
}




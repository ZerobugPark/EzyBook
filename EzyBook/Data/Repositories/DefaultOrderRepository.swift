//
//  DefaultOrderRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/16/25.
//

import Foundation

struct DefaultOrderRepository: OrderCreateRepository, OrderListLookUpRepository {
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func requestOrderCreate(_ router: OrderRequest.Post) async throws -> OrderCreateEntity  {
        
        let data = try await networkService.fetchData(dto: OrderCreateResponseDTO.self, router)
        
        return data.toEntity()
        
    }
    
    
    func requestOrderListLookUp(_ router: OrderRequest.Get) async throws -> [OrderEntity]  {
        
        let data = try await networkService.fetchData(dto: OrderListResponseDTO.self, router)
        
        return data.toEntity()
        
    }
    
    //TODO: Keep list 조회
}




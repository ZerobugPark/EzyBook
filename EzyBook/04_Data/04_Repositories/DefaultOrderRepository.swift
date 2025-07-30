//
//  DefaultOrderRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/16/25.
//

import Foundation

final class DefaultOrderRepository: OrderCreateRepository, OrderListLookUpRepository {

    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
        
    /// 주문 생성
    func requestOrderCreate(_ activityId: String, _ reservationItemName: String, _ reservationItemTime: String, _ participantCount: Int, _ totalPrice: Int) async throws -> OrderCreateEntity {
        
        
        let dto = OrderCreateRequestDTO(
            activityId: activityId,
            reservationItemName: reservationItemName,
            reservationItemTime: reservationItemTime,
            participantCount: participantCount,
            totalPrice: totalPrice
        )
        
        let router = OrderRequest.Post.order(dto: dto)
        let data = try await networkService.fetchData(dto: OrderCreateResponseDTO.self, router)
        
        return data.toEntity()
    }
    

    /// 주문 내역 조회
    func requestOrderListLookUp() async throws -> [OrderEntity]  {
        
        let router = OrderRequest.Get.order
        
        let data = try await networkService.fetchData(dto: OrderListResponseDTO.self, router)
        
        return data.toEntity()
        
    }
    
    //TODO: Keep list 조회
}




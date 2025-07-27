//
//  OrderImpl.swift
//  EzyBook
//
//  Created by youngkyun park on 7/25/25.
//

import Foundation


// MARK: 주문 생성
final class DefaultCreateOrderUseCase: CreateOrderUseCase {
    
    private let repo: OrderCreateRepository
    
    init(repo: OrderCreateRepository) {
        self.repo = repo
    }
    
}

extension DefaultCreateOrderUseCase {
    func execute(activityId: String, reservationItemName: String, reservationItemTime: String, participantCount: Int, totalPrice: Int
    ) async throws -> OrderCreateEntity {
        
        try await repo.requestOrderCreate(activityId, reservationItemName, reservationItemTime, participantCount, totalPrice)

    }
}


// MARK: 주문내역 조회
final class DefaultOrderListLookupUseCase: OrderListLookUpUseCase {
    
    private let repo: OrderListLookUpRepository
    
    init(repo: OrderListLookUpRepository) {
        self.repo = repo
    }
    
}

extension DefaultOrderListLookupUseCase {
    func execute() async throws -> [OrderEntity] {
        try await repo.requestOrderListLookUp()
    }
}

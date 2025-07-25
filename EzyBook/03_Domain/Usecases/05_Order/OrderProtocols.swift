//
//  OrderProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 7/25/25.
//

import Foundation


protocol CreateOrderUseCase {
    func execute(activityId: String, reservationItemName: String, reservationItemTime: String, participantCount: Int, totalPrice: Int
    ) async throws -> OrderCreateEntity
}

protocol OrderListLookUpUseCase {
    func execute() async throws -> [OrderEntity]
}
    

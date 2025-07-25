//
//  OrderRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/16/25.
//

import Foundation


protocol OrderCreateRepository {
    func requestOrderCreate(_ activityId: String, _ reservationItemName: String, _ reservationItemTime: String, _ participantCount: Int, _ totalPrice: Int) async throws -> OrderCreateEntity
    
}

protocol OrderListLookUpRepository {
    func requestOrderListLookUp() async throws -> [OrderEntity]
}

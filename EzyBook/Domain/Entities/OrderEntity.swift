//
//  OrderEntity.swift
//  EzyBook
//
//  Created by youngkyun park on 6/16/25.
//

import Foundation

struct OrderCreateEntity {
    let orderId: String
    let orderCode: String
    let totalPrice: Int
    let createdAt: String
    let updatedAt: String
    
    init(dto: OrderCreateResponseDTO) {
        self.orderId = dto.orderId
        self.orderCode = dto.orderCode
        self.totalPrice = dto.totalPrice
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
    }
    
}


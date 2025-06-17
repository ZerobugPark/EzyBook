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

/// 주문내역 조회
struct OrderEntity {
    let orderId: String
    let orderCode: String
    let totalPrice: Int
    let review: ReviewRatingEntity
    let reservationItemName: String
    let reservationItemTime: String
    let participantCount: Int
    let activity : ActivitySummaryEntity
    let paidAt: String
    let createdAt: String
    let updatedAt: String
    
    
    init(dto: OrderResponseDTO) {
        self.orderId = dto.orderId
        self.orderCode = dto.orderCode
        self.totalPrice = dto.totalPrice
        self.review = ReviewRatingEntity(dto: dto.review)
        self.reservationItemName = dto.reservationItemName
        self.reservationItemTime = dto.reservationItemTime
        self.participantCount = dto.participantCount
        self.activity = ActivitySummaryEntity(dto: dto.activity)
        self.paidAt = dto.paidAt
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
    }

}

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
    let review: ReviewInfoEntity?
    let reservationItemName: String
    let reservationItemTime: String
    let participantCount: Int
    let activity : ActivitySummaryOrderEntity
    let paidAt: String
    let createdAt: String
    let updatedAt: String
    
    
    init(dto: OrderResponseDTO) {
        self.orderId = dto.orderId
        self.orderCode = dto.orderCode
        self.totalPrice = dto.totalPrice
        self.review = dto.review.map { ReviewInfoEntity(dto: $0) }
        self.reservationItemName = dto.reservationItemName
        self.reservationItemTime = dto.reservationItemTime
        self.participantCount = dto.participantCount
        self.activity = ActivitySummaryOrderEntity(dto: dto.activity)
        self.paidAt = dto.paidAt
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
    }

}


struct ActivitySummaryOrderEntity {
    let id: String                // 액티비티 ID
    let title: String?             // 액티비티 제목
    let country: String?           // 국가
    let category: String?          // 카테고리
    let thumbnails: [String]        //썸네일
    let geolocation:  ActivityGeolocationEntity // 위치 정보
    let price: ActivityPriceEntity             // 가격 정보
    let tags: [String]            // 태그 목록
    let pointReward: Int?       // 포인트 적립 정보
    
    
    init(dto: ActivitySummaryResponseDTO_Order) {
        self.id = dto.id
        self.title = dto.title
        self.country = dto.country
        self.category = dto.category
        self.thumbnails = dto.thumbnails
        self.geolocation = ActivityGeolocationEntity.init(dto: dto.geolocation)
        self.price = ActivityPriceEntity.init(dto: dto.price)
        self.tags = dto.tags
        self.pointReward = dto.pointReward
    }
}


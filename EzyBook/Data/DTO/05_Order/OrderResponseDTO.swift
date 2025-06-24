//
//  OrderResponseDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 6/12/25.
//

import Foundation

struct OrderCreateResponseDTO: Decodable, EntityConvertible {
    let orderId: String
    let orderCode: String
    let totalPrice: Int
    let createdAt: String
    let updatedAt: String
   
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case orderCode = "order_code"
        case totalPrice = "total_price"
        case createdAt
        case updatedAt
     }

    
}


struct OrderListResponseDTO: Decodable, EntityConvertible {
    let data: [OrderResponseDTO]
}


/// 리뷰랑 별점이 작성되어있다면, 함께 표시
struct OrderResponseDTO: Decodable {
    let orderId: String
    let orderCode: String
    let totalPrice: Int
    let review: ReviewInfoResponseDTO?
    let reservationItemName: String
    let reservationItemTime: String
    let participantCount: Int
    let activity :ActivitySummaryResponseDTO_Order
    let paidAt: String
    let createdAt: String
    let updatedAt: String
    
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case orderCode = "order_code"
        case totalPrice = "total_price"
        case review
        case reservationItemName = "reservation_item_name"
        case reservationItemTime = "reservation_item_time"
        case participantCount = "participant_count"
        case activity
        case paidAt
        case createdAt
        case updatedAt
     }
    
}

struct ActivitySummaryResponseDTO_Order: Decodable {
    let id: String                // 액티비티 ID
    let title: String?             // 액티비티 제목
    let country: String?           // 국가
    let category: String?          // 카테고리
    let thumbnails: [String]        //썸네일
    let geolocation: ActivityGeolocationDTO   // 위치 정보
    let price: ActivityPriceDTO             // 가격 정보
    let tags: [String]            // 태그 목록
    let pointReward: Int?       // 포인트 적립 정보

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case country
        case category
        case thumbnails
        case geolocation
        case price
        case tags
        case pointReward = "point_reward"
    }
}

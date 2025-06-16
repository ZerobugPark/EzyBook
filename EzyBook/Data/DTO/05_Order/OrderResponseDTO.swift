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



struct OrderListResponseDTO: Decodable {
    let data: OrderResponseDTO
}


/// 리뷰랑 별점이 작성되어있다면, 함께 표시
struct OrderResponseDTO: Decodable {
    let orderId: String
    let orderCode: String
    let totalPrice: Int
    let review: ReviewRatingResponseDTO
    let reservationItemName: String
    let reservationItemTime: String
    let participantCount: Int
    let activity :ActivitySummaryResponseDTO
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

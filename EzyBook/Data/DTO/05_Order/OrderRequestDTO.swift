//
//  OrderRequestDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 6/12/25.
//

import Foundation

/// 주문생성
struct OrderCreateRequestDTO: Encodable {
    let activityId: String
    let reservationItemName: String
    let reservationItemTime: String
    let participantCount: Int
    let totalPrice: Int
   
    enum CodingKeys: String, CodingKey {
        case activityId = "activity_id"
        case reservationItemName = "reservation_item_name"
        case reservationItemTime = "reservation_item_time"
        case participantCount = "participant_count"
        case totalPrice = "total_price"
     }

    
}

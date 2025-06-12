//
//  OrderResponseDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 6/12/25.
//

import Foundation

struct OrderCreateResponseDTO: Decodable {
    let order_Id: String
    let orderCode: String
    let totalPrice: String
    let createdAt: String
    let updatedAt: String
   
    enum CodingKeys: String, CodingKey {
        case order_Id = "order_id"
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
///
struct OrderResponseDTO: Decodable {
    
}

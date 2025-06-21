//
//  ReviewRequestDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 6/7/25.
//

import Foundation

/// 리뷰 작성
struct ReviewWriteRequestDTO: Encodable {
    let content: String
    let rating: Int
    let reviewImageUrls: [String]
    let orderCode: String
    
    enum CodingKeys: String, CodingKey {
        case content
        case rating
        case reviewImageUrls = "review_image_urls"
        case orderCode = "order_code"
     }
}


/// 리뷰 수정
struct ReviewModifyRequestDTO: Encodable {
    let content: String
    let rating: Int
    let reviewImageUrls: String
    
    enum CodingKeys: String, CodingKey {
        case content
        case rating
        case reviewImageUrls = "review_image_urls"
     }
}

//
//  ReviewResponseDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 6/7/25.
//

import Foundation

/// 파일 업로드
struct ReviewImageResponseDTO: Decodable, EntityConvertible {
    let reviewImageUrls: [String]
    
    enum CodingKeys: String, CodingKey {
        case reviewImageUrls = "review_image_urls"
    }

}



/// 리뷰 목록 조회
struct ReviewListResponseDTO: Decodable, EntityConvertible {
    
    let data: ReviewResponseDTO
    let nextCursor: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

/// 리뷰 작성/수정 성공
struct ReviewResponseDTO: Decodable, EntityConvertible {
    let reviewId: String  // 리뷰 ID
    let content: String //리뷰 내용
    let rating: Int // 평점
    let reviewImageUrls: [String] // 리뷰 이미지 URL 배열
    let reservationItemName: String // 예약한 액티비티 예약 일자
    let reservationItemTime: String // 예약한 액티비티 예약 시간
    let creator: UserInfoResponseDTO
    let userTotalReviewCount: Int // 리뷰 작성자의 총 리뷰 수
    let userTotalRating: Float  // 리뷰 작성자의 평균 별점
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case reviewId = "review_id"
        case content
        case rating
        case reviewImageUrls = "review_image_urls"
        case reservationItemName = "reservation_item_name"
        case reservationItemTime = "reservation_item_time"
        case creator
        case userTotalReviewCount = "user_total_review_count"
        case userTotalRating = "user_total_rating"
        case createdAt
        case updatedAt
    }
    
}

/// 별점별 리뷰 개수

struct ReViewRatingListResponseDTO: Decodable, EntityConvertible {
    let data: [ReviewRatingResponseDTO]
}

struct ReviewRatingResponseDTO: Decodable {
    let rating: Int
    let count: Int
}


struct ReviewInfoResponseDTO: Decodable {
    let id: String
    let rating: Int
}

struct UserReviewResponseDTO: Decodable, EntityConvertible {
    let reviewID: String
    let content: String
    let rating: Int
    let activity: ActivitySummaryResponseDTO_Post
    let reviewImageURLs: [String]
    let reservationItemName: String
    let reservationItemTime: String
    let creator: UserInfoResponseDTO
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case reviewID = "review_id"
        case content
        case rating
        case activity
        case reviewImageURLs = "review_image_urls"
        case reservationItemName = "reservation_item_name"
        case reservationItemTime = "reservation_item_time"
        case creator
        case createdAt
        case updatedAt
    }
}


struct ActivitySummaryResponseDTO_Post: Decodable {
    let id: String
    let title: String?
    let country: String?
    let category: String?
    let thumbnails: [String]
    let geolocation: ActivityGeolocationDTO
    let price: ActivityPriceDTO
    let tags: [String]
    let pointReward: Int
    let isAdvertisement: Bool
    let isKeep: Bool
    let keepCount: Int

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
        case isAdvertisement = "is_advertisement"
        case isKeep = "is_keep"
        case keepCount = "keep_count"
    }
}


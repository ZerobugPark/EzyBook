//
//  ReviewEntity.swift
//  EzyBook
//
//  Created by youngkyun park on 6/7/25.
//

import Foundation

struct ReviewImageEntity {
    let reviewImageUrls: [String]
    
    init(dto: ReviewImageResponseDTO) {
        self.reviewImageUrls = dto.reviewImageUrls
    }
}


/// 회원가입
struct ReviewListEntity {
    let data: ReviewResponseEntity
    let nextCursor: String
    
    init(dto: ReviewListResponseDTO) {
        self.data = dto.data.toEntity()
        self.nextCursor = dto.nextCursor
    }
    
}

/// 리뷰 작성/수정 성공
struct ReviewResponseEntity {
    let reviewId: String  // 리뷰 ID
    let content: String //리뷰 내용
    let rating: Int // 평점
    let reviewImageUrls: [String] // 리뷰 이미지 URL 배열
    let reservationItemName: String // 예약한 액티비티 예약 일자
    let reservationItemTime: String // 예약한 액티비티 예약 시간
    let creator: UserInfoResponseEntity
    let userTotalReviewCount: Int // 리뷰 작성자의 총 리뷰 수
    let userTotalRating: Float  // 리뷰 작성자의 평균 별점
    let createdAt: String
    let updatedAt: String
    
    init(dto: ReviewResponseDTO) {
        self.reviewId = dto.reviewId
        self.content = dto.content
        self.rating = dto.rating
        self.reviewImageUrls = dto.reviewImageUrls
        self.reservationItemName = dto.reservationItemName
        self.reservationItemTime = dto.reservationItemTime
        self.creator = UserInfoResponseEntity(dto: dto.creator)
        self.userTotalReviewCount = dto.userTotalReviewCount
        self.userTotalRating = dto.userTotalRating
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
    }
    
}


struct ReviewRatingListEntity {
    let data: [ReviewRatingEntity]
    
    /// 전체 평균 별점 (가중 평균)
    /// $0은 = 누적값(accumulator)
    /// $1은 = 현재 순회 중인 요소(element)
    var rating: Double {
        let totalScore = data.reduce(0) { $0 + ($1.rating * $1.count) }
        let totalCount = data.reduce(0) { $0 + $1.count }
        guard totalCount > 0 else { return 0.0 }
        return Double(totalScore) / Double(totalCount)
    }
    
    /// 전체 리뷰 수
    var totalCount: Int {
        data.reduce(0) { $0 + $1.count }
    }
    
    
    init(dto: ReViewRatingListResponseDTO) {
        self.data = dto.data.map { ReviewRatingEntity(dto: $0) }
    }
}

struct ReviewRatingEntity {
    let rating: Int
    let count: Int
    
    init(dto: ReviewRatingResponseDTO) {
        self.rating = dto.rating
        self.count = dto.count
    }
}



struct ReviewInfoEntity: Equatable, Hashable {
    let id: String
    let rating: Int
    
    init(dto: ReviewInfoResponseDTO) {
        self.id = dto.id
        self.rating = dto.rating
    }
    
}


struct UserReviewEntity {
    let reviewID: String
    let content: String
    let rating: Int
    let activity: ActivitySummaryEntity_Post
    let reviewImageURLs: [String]
    let reservationItemName: String
    let reservationItemTime: String
    let creator: UserInfoResponseEntity
    let createdAt: String
    let updatedAt: String
    
    init(dto: UserReviewResponseDTO) {
        self.reviewID = dto.reviewID
        self.content = dto.content
        self.rating = dto.rating
        self.activity =  ActivitySummaryEntity_Post.init(dto: dto.activity)
        self.reviewImageURLs = dto.reviewImageURLs
        self.reservationItemName = dto.reservationItemName
        self.reservationItemTime = dto.reservationItemTime
        self.creator =  UserInfoResponseEntity(dto: dto.creator)
        self.createdAt = dto.createdAt
        self.updatedAt = dto.updatedAt
    }
}


struct ActivitySummaryEntity_Post {
    let id: String
    let title: String?
    let country: String?
    let category: String?
    let thumbnails: [String]
    let geolocation: ActivityGeolocationEntity
    let price: ActivityPriceEntity
    let tags: [String]
    let pointReward: Int
    let isAdvertisement: Bool
    let isKeep: Bool
    let keepCount: Int
    
    init(dto: ActivitySummaryResponseDTO_Post) {
        self.id = dto.id
        self.title = dto.title
        self.country = dto.country
        self.category = dto.category
        self.thumbnails = dto.thumbnails
        self.geolocation =  ActivityGeolocationEntity(dto: dto.geolocation)
        self.price = ActivityPriceEntity(dto: dto.price)
        self.tags = dto.tags
        self.pointReward = dto.pointReward
        self.isAdvertisement = dto.isAdvertisement
        self.isKeep = dto.isKeep
        self.keepCount = dto.keepCount
    }

}

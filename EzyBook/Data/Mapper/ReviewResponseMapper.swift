//
//  ReviewResponseMapper.swift
//  EzyBook
//
//  Created by youngkyun park on 6/7/25.
//

import Foundation

extension ReviewImageResponseDTO {
    func toEntity() -> ReviewImageEntity {
        return ReviewImageEntity(dto: self)
    }
}


extension ReviewListResponseDTO {
    func toEntity() -> ReviewListEntity {
        return ReviewListEntity(dto: self)
    }
}

extension ReviewResponseDTO {
    func toEntity() -> ReviewResponseEntity {
        return ReviewResponseEntity(dto: self)
    }
}



/// 별점별 리뷰 개수
extension ReViewRatingListResponseDTO {
    func toEntity() -> ReviewRatingListEntity {
        return ReviewRatingListEntity(dto: self)
    }
}

extension ReviewInfoResponseDTO {
    func toEntity() -> ReviewInfoEntity {
        return ReviewInfoEntity(dto: self)
    }
}

extension UserReviewResponseDTO {
    func toEntity() -> UserReviewEntity {
        return UserReviewEntity(dto: self)
    }
}

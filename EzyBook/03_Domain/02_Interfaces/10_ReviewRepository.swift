//
//  ReviewRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import SwiftUI

protocol ReviewRatingListRepository {
    func requestReviewRatingist(_ id: String) async throws ->  ReviewRatingListEntity
}

protocol ReviewImageUploadRepository {
    func requestReviewUploadImage(_ id: String, _ images: [UIImage]) async throws -> ReviewImageEntity

}

protocol ReviewWriteRepository {
    
    func requestWriteReview(_ id: String, _ content: String, _ rating: Int, _ reviewImageUrls: [String]?, _ orderCode: String) async throws -> UserReviewEntity
    
}

protocol ReviewModifyRepository {
    func requestModifyReview(_ id: String, _ content: String?, _ rating: Int?, _ reviewImageUrls: [String]?, _ reviewID: String) async throws -> UserReviewEntity
    
}


protocol ReviewDeleteRepository {
    
    func requestDeleteReview(_ id: String, _ reviewID: String) async throws
    
}




protocol ReviewDetailRepository {
    func reqeustReviewDetailList(_ activityID: String, _ reviewID: String) async throws -> UserReviewEntity
}


protocol ActivityReviewListRepository {
    func requestActivityReviewList(_ activityID: String) async throws -> ReviewListEntity
}


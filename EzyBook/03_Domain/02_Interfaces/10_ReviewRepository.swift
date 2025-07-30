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
    
    func requestWriteReivew(_ id: String, _ content: String, _ rating: Int, _ reviewImageUrls: [String]?, _ orderCode: String) async throws -> UserReviewEntity
    
}


protocol ReviewDetailRepository {
    func reqeustReviewList(_ activityID: String, _ reviewID: String) async throws -> UserReviewEntity
}

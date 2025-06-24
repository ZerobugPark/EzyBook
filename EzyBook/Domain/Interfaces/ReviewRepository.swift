//
//  ReviewRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/10/25.
//

import Foundation

protocol ReviewRatingListRepository {
    func requestReviewRatingist(_ router: ReViewRequest.Get) async throws ->  ReviewRatingListEntity
}

protocol ReviewImageUploadRepository {
    func requestReviewUploadImage(_ router: ReViewRequest.Multipart) async throws -> ReviewImageEntity

}

protocol ReviewWriteRepository {
    
    func requestWriteReivew(_ router: ReViewRequest.Post) async throws -> UserReviewEntity
    
}


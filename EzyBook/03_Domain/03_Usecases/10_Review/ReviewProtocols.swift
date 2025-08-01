//
//  ReviewProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 7/25/25.
//

import SwiftUI

protocol ReviewImageUpload {
    func execute(id: String, images: [UIImage]) async throws -> ReviewImageEntity
}

protocol ReViewWriteUseCase {
    func execute(
        id: String, content: String, rating: Int, reviewImageUrls: [String]?, orderCode: String) async throws -> UserReviewEntity
}

protocol ReviewRatingLookUpUseCase {
    func execute(id: String) async throws -> ReviewRatingListEntity
}

protocol ReviewDetailUseCase {
    func execute(activityID: String, reviewID: String) async throws -> UserReviewEntity
}

protocol ActivityReviewLookUpUseCase {
    func execute(activityID: String) async throws -> ReviewListEntity
}

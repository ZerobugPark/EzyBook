//
//  ReviewRatingListRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/7/25.
//

import Foundation


protocol ReviewRatingListRepository {
    func requestReviewRatingist(_ router: ReviewGetRequest) async throws ->  ReviewRatingListEntity 
}



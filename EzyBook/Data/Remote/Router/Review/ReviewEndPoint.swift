//
//  ReviewEndPoint.swift
//  EzyBook
//
//  Created by youngkyun park on 6/7/25.
//

import Foundation

enum ReviewEndPoint: APIEndPoint {

    case reviewFiles(id: String) // 리뷰 파일 업로드
    case writeReview(id: String) // 리뷰 작성
    case reviewList(id: String) // 리뷰 목록 조회
    case reviewDetail(id: String, reviewID: String) // 리뷰 상세 조회
    case reviewModify(id: String, reviewID: String) // 리뷰 수정
    case reviewDelete(id: String, reviewID: String) // 리뷰 삭제
    case reviewRatingList(id: String) // 리뷰 개수 조회

  
    var path: String {
        switch self {
        case .reviewFiles(let id):
            return "/v1/activities/\(id)/reviews/files"
        case .writeReview(let id), .reviewList(let id):
            return "/v1/activities/\(id)/reviews"
        case .reviewDetail(let id, let reviewID),
                .reviewModify(let id, let reviewID),
                .reviewDelete(let id, let reviewID):
            return "/v1/activities/\(id)/reviews/\(reviewID)"
        case .reviewRatingList(let id):
            return "/v1/activities/\(id)/reviews/reviews-ratings"
        }
        
    }

}

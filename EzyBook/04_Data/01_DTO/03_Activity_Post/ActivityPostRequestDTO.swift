//
//  ActivityPostRequestDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 8/1/25.
//

import Foundation

///게시글 작성
struct ActivityPostRequestDTO: Encodable {
    
    let country: String
    let category: String
    let title: String
    let content: String
    let activityID: String
    let latitude: Double //위도
    let longitude: Double //경도
    let files: [String]
    
    
    enum CodingKeys: String, CodingKey {
        case country
        case category
        case title
        case content
        case activityID = "activity_id"
        case latitude
        case longitude
        case files
     }
}

///게시글 수정
struct ActivityPostModifyRequestDTO: Encodable {
    
    let country: String? = nil
    let category: String? = nil
    let title: String?
    let content: String?
    let activityID: String? = nil
    let latitude: String? = nil
    let longitude: String? = nil
    let files: [String]?
    
    
    enum CodingKeys: String, CodingKey {
        case country
        case category
        case title
        case content
        case activityID = "activity_id"
        case latitude
        case longitude
        case files
     }
}


// MARK: Query
///게시글 조회 Query
struct ActivityPostLookUpQuery {
    let country: String?
    let category: String?
    let longitude: String?
    let latitude: String?
    let maxDistance: String?
    let limit: Int?
    let next: String?
    let orderBy: String?

}

///게시글 작성 조회 또는 내가 좋아한 게시글
struct MyActivityQuery {
    
    let country: String?
    let category: String?
    let limit: String? 
    let next: String?

}
struct ActivityPostLikeRequestDTO: Encodable {
    
    let likeStatus: Bool
    
    enum CodingKeys: String, CodingKey {
         case likeStatus = "like_status"
     }
}

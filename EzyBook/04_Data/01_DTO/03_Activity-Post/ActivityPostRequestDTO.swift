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
    let latitude: String //위도
    let longitude: String //경도
    let files: String
    
    
    enum CodingKeys: String, CodingKey {
         case activityID = "activity_id"
     }
}

///게시글 수정
struct ActivityPostModifyRequestDTO: Encodable {
    
    let country: String?
    let category: String?
    let title: String?
    let content: String?
    let activityID: String?
    let latitude: String?
    let longitude: String?
    let files: String?
    
    
    enum CodingKeys: String, CodingKey {
         case activityID = "activity_id"
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
    
    let country: String
    let category: String
    let limit: String //위도
    let next: String?

}

//
//  ActivityRequestDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 5/23/25.
//

import Foundation


/// 액티비티 (요약)목록 조회
/// 내가 킵한 액티비티 조회
struct ActivitySummaryListRequestDTO: Encodable {
    let country: String?
    let category: String?
    let limit: String
    let next: String?
}

/// 액티비티 상세  조회
struct ActivityDetailRequestDTO: Encodable {
    let activityId: String
    
    enum CodingKeys: String, CodingKey {
         case activityId = "activity_id"
     }
}

/// 액티비티 킵
struct ActivityKeepRequestDTO: Encodable {
    let status: Bool
    
    enum CodingKeys: String, CodingKey {
         case status = "keep_status"
     }
}

/// New 액티비티 목록 조회
struct ActivityNewSummaryListRequestDTO: Encodable {
    let country: String?
    let category: String?
}

/// 액티비티 검색
struct ActivitySearchListRequestDTO: Encodable {
    let title: String
}

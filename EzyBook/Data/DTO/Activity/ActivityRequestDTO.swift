//
//  ActivityRequestDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 5/23/25.
//

import Foundation

/// 파일업로드
struct ActivityFileUploadRequestDTO: Encodable {
    
}

/// 액티비티 (요약)목록 조회
/// 내가 킵한 액티비티 조회
struct ActivitySummaryListRequestDTO: Encodable {
    let country: String?
    let category: String?
    let limit: String?
    let next: String?
}

/// 액티비티 상세  조회
/// 액티비티 킵
struct ActivityDetailRequestDTO: Encodable {
    let activityId: String
    
    enum CodingKeys: String, CodingKey {
         case activityId = "activity_id"
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

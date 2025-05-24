//
//  ActivityEndPoint.swift
//  EzyBook
//
//  Created by youngkyun park on 5/24/25.
//

import Foundation

enum ActivityEndPoint: APIEndPoint {

    case activityFiles //액티비피 파일 업로드
    case activityList //액티비피 목록 조회
    case activityDetail(id: String) //액티비피 킵/킵취소
    case activityKeep(id: String) //액티비피 킵/킵취소
    case newActivities //새로운 액티비미 목록 조회
    case activitySearch // 액티비티 검색
    case keptActivities // 내가 킵한 액티비티 리스트

    
    /// Path와 Query 기준은 뭘까? (Answered by Gpt)
    /// path:    어떤 리소스에 접근할지를 명확히 지정할 때 (ID, 고정된 리소스 구조)
    /// query:    검색, 필터링, 정렬, 페이지네이션 등 추가적인 옵션일 때
    
    
    var path: String {
        switch self {
        case .activityFiles:
            return "/v1/activities/files"
        case .activityList:
            return "/v1/activities/"
        case .activityDetail(let id):
            return "/v1/activities/\(id)"
        case .activityKeep(let id):
            return "/v1/activities/\(id)/keep"
        case .newActivities:
            return "/v1/activities/new"
        case .activitySearch:
            return "/v1/activities/search"
        case .keptActivities:
            return "/v1/activities/keeps/me"
        }
    }

}

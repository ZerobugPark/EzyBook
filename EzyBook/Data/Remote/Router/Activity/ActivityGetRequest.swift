//
//  ActivityRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 5/24/25.
//

import Foundation
import Alamofire

enum ActivityGetRequest: GetRouter {
    
    case activityFiles
    case activityList(param: ActivitySummaryListRequestDTO)
    case activityDetail(param: ActivityDetailRequestDTO)
    case newActivities(param: ActivityNewSummaryListRequestDTO)
    case serachActiviy(param: ActivitySearchListRequestDTO)
    
    var requiresAuth: Bool {
        true
    }
    
    var endpoint: URL? {
        switch self {
        case .activityFiles:
            ActivityEndPoint.activityFiles.requestURL
        case .activityList:
            ActivityEndPoint.activityList.requestURL
        case .activityDetail(let param):
            ActivityEndPoint.activityDetail(id: param.activityId).requestURL
        case .newActivities:
            ActivityEndPoint.newActivities.requestURL
        case .serachActiviy:
            ActivityEndPoint.activitySearch.requestURL
        }
    }
    
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: HTTPHeaders {
        [
            "SeSACKey": APIConstants.apiKey
        ]
        
    }
    
    var parameters: Parameters? {
        switch self {
        case .activityList(let param):
            /// 파라미터 타입으로 할 경우 옵셔널에 대한 대응이 불가능해서
            /// return시 업 캐스팅 처리
            /// [String: String]은 [String: Any]의 하위 타입
            let result: [String: Any?] = [
                 "country": param.country,
                 "category": param.category,
                 "limit": param.limit,
                 "next": param.next
             ]
            
            let filtered = result.compactMapValues { $0 } // 옵셔널 제거
            return filtered.isEmpty ? nil : filtered as Parameters // 업캐스팅
        case .newActivities(let param):
            let result: [String: Any?] = [
                 "country": param.country,
                 "category": param.category
             ]
            
            let filtered = result.compactMapValues { $0 }
            return filtered.isEmpty ? nil : filtered as Parameters // 업캐스팅
        case .serachActiviy(let param):
            return ["title": param.title]
        default:
            return nil
        }
    }
}

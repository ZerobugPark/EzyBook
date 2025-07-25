//
//  OrderEndPoint.swift
//  EzyBook
//
//  Created by youngkyun park on 6/12/25.
//

import Foundation

enum OrderEndPoint: APIEndPoint {

    case order //주문생성 및 내역 조회
    
    
    /// Path와 Query 기준은 뭘까? (Answered by Gpt)
    /// path:    어떤 리소스에 접근할지를 명확히 지정할 때 (ID, 고정된 리소스 구조)
    /// query:    검색, 필터링, 정렬, 페이지네이션 등 추가적인 옵션일 때
    
    var path: String {
        switch self {
        case .order:
            return "/v1/orders"
        }
    }

}

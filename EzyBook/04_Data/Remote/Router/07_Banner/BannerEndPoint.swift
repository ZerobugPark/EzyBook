//
//  BannerEndPoint.swift
//  EzyBook
//
//  Created by youngkyun park on 7/20/25.
//

import Foundation

enum BannerEndPoint: APIEndPoint {

    case banner // 배너 조회
    
    var path: String {
        switch self {
        case .banner:
            return "/v1/banners/main"
        }
    }

}

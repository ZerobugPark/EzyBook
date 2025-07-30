//
//  PaymentEndPoint.swift
//  EzyBook
//
//  Created by youngkyun park on 6/17/25.
//

import Foundation

enum PaymentEndPoint: APIEndPoint {

    case vaildation //주문생성 및 내역 조회
    case paymentLookUp(code: String)

    
    var path: String {
        switch self {
        case .vaildation:
            return "/v1/payments/validation"
        case .paymentLookUp( let code):
            return "/v1/payments/\(code)"
        }
    }

}

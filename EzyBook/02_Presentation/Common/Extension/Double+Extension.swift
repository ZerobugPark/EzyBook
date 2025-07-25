//
//  Double+Extension.swift
//  EzyBook
//
//  Created by youngkyun park on 5/28/25.
//

import Foundation

extension Double {
    /// 소수점이 있으면 보여주고, 없으면 안 보여주는 문자열 포맷 반환
    func formattedPercentage(maximumFractionDigits: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.numberStyle = .decimal
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

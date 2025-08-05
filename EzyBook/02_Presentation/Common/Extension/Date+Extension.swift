//
//  Date+Extension.swift
//  EzyBook
//
//  Created by youngkyun park on 8/5/25.
//

import Foundation


extension Date {
    func toISOString() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
}

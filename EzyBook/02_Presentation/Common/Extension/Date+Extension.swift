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


// MARK: 채팅 구분선
extension Date {
    func toDisplayString(format: String = "yyyy년 M월 d일 (E)") -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(self) {
            return "오늘"
        } else if calendar.isDateInYesterday(self) {
            return "어제"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: self)
        }
    }
}

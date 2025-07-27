//
//  String+Extension.swift
//  EzyBook
//
//  Created by youngkyun park on 5/20/25.
//

import Foundation
import CryptoKit

//Vaildation
extension String {
    
    /// 이메일 유효성 검사 (서버에 있는데, 굳이 내가 체크를 할까?)
    /// ^:  문자열의 시작,
    /// [A-Z0-9a-z._%+-]+: 이메일의 앞 부분
    /// @: @기호 필수
    /// \. :도메인과 확장자 구분 및 Dot(.)필수
    /// [A-Za-z]{2,}: 도메인 확장자 (2글자 이상)
    /// $ 문자열 끝
    func validateEmail() -> Bool {
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    /// 비밀번호 복잡도 검사
    func validatePasswordCmplexEnough() -> Bool {
        let regex = #"^(?=.*[a-zA-Z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]+$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    /// 비밀번호 길이 검사
    func validatePasswordLength() -> Bool {
        return self.count > 7
    }
    
    func isPasswordValid() -> Bool {
        return self.validatePasswordLength() && self.validatePasswordCmplexEnough()
    }
    
}


/// 암호화
extension String {
    func sha256() -> String {
        let inputData = Data(self.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}


// MARK: - String Extension for Date Parsing and Formatting
extension String {
    func toDate(using formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()) -> Date? {
        return formatter.date(from: self)
    }
    
    func toDisplayDate(format: String = "yyyy-MM-dd") -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = format
        displayFormatter.locale = Locale(identifier: "ko_KR")
        
        if let date = isoFormatter.date(from: self) {
            return displayFormatter.string(from: date)
        } else {
            return self
        }
    }
}


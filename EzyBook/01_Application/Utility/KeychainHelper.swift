//
//  KeychainHelper.swift
//  EzyBook
//
//  Created by youngkyun park on 8/8/25.
//

import Foundation

/// Keychain 전체 삭제 유틸
struct KeychainHelper {
    /// 모든 Keychain 클래스 항목을 삭제
    static func deleteAllItems() {
        let secItemClasses = [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity
        ]
        for itemClass in secItemClasses {
            let query: [CFString: Any] = [kSecClass: itemClass]
            SecItemDelete(query as CFDictionary)
        }
    }
    
    /// 최소 하나 이상의 Generic Password가 존재하는지 체크
    static func hasAnyItem() -> Bool {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecReturnAttributes: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        return status == errSecSuccess
    }
}

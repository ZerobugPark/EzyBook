//
//  DefaultKeychainTokenRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/20/25.
//

import Foundation

final class DefaultKeychainTokenRepository: TokenRepository {
    
    private let keyChainManger: KeyChainProtocol
    
    init(keyChainManger: KeyChainProtocol) {
        self.keyChainManger = keyChainManger
    }
    
    func saveToken(key: String, value: String) -> Bool {
        keyChainManger.saveToken(key: key, value: value)
    }
    
    func loadToken(key: String) -> String? {
        keyChainManger.loadToken(key: key)
    }
    
    func deleteToken(key: String) -> Bool {
        keyChainManger.deleteToken(key: key)

    }
}

//
//  KeychainTokenRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import Foundation

final class KeychainTokenRepository: EzyBookTokenRepository {
    
    private let keyChainManger: KeyChainProtocol
    
    init(keyChainManger: KeyChainProtocol) {
        self.keyChainManger = keyChainManger
    }
    
    func save(key: String, value: String) -> Bool {
        keyChainManger.saveToken(key: key, value: value)
    }
    
    func loadRefreshToken(key: String) -> String? {
        keyChainManger.loadToken(key: key)
    }
    
    func deleteToken(key: String) -> Bool {
        keyChainManger.deleteToken(key: key)

    }
}

//
//  SocketServicePool.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import Foundation
import SocketIO


final class SocketServicePool {
    private var services: [String: SocketService] = [:] // roomID → SocketService
    private let keyChain: TokenStorage
    
    init(keyChain: TokenStorage) {
        self.keyChain = keyChain
    }
    
    func service(for roomID: String) -> SocketService {
        if let existing = services[roomID] {
            return existing
        }
        let newService = DefaultSocketService(roomID: roomID, keyChain: keyChain)
        services[roomID] = newService
        return newService
    }
    
    func disconnectAll() {
        services.values.forEach { $0.disconnect() }
        services.removeAll()
    }
    
    deinit {
        print(#function, "테스트")
    }
}

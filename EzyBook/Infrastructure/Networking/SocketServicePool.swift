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
    
    func service(for roomID: String) -> SocketService {
        if let existing = services[roomID] {
            return existing
        }
        let newService = DefaultSocketService(roomID: roomID)
        services[roomID] = newService
        return newService
    }
    
    func disconnectAll() {
        services.values.forEach { $0.disconnect() }
        services.removeAll()
    }
    
}

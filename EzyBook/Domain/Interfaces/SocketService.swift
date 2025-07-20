//
//  SocketService.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import Foundation

protocol SocketService {
    func connect()
    func disconnect()
    var onConnect: (() -> Void)? { get set }
    var onMessageReceived: ((ChatMessageEntity) -> Void)? { get set }
}

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
    var onMessageReceived: ((String) -> Void)? { get set }
}

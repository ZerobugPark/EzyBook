//
//  DefaultSocketService.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import Foundation
import SocketIO

final class DefaultSocketService: SocketService {
    
    private let roomID: String
    var onMessageReceived: ((String) -> Void)?
    
    private var isConnected: Bool = false
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    
    init(roomID: String) {
        self.roomID = roomID
    }
    
    func connect() {
        guard !isConnected else { return }
        
        
        let strURL = APIConstants.baseURL + "/chats-" + roomID
        let url = URL(string: strURL)!
        manager = SocketManager(socketURL: url, config: [.log(true), .compress])
        socket = manager?.defaultSocket
        
        addEventHandlers()
        
        socket?.connect()
        
        isConnected = true
    }
    
    func disconnect() {
        guard isConnected else { return }
        isConnected = false
        
        socket?.disconnect()
        print("\(roomID) 소켓 연결 해제")
    }
    
    private func addEventHandlers() {
        socket?.on(clientEvent: .connect) { data, ack in
            print("🟢 [\(self.roomID)] 소켓 연결됨")
            self.socket?.emit("join_room", self.roomID)
        }
        
        socket?.on("chat_message") { data, ack in
            if let dict = data.first as? [String: Any],
               let message = dict["message"] as? String {
                print("📩 [\(self.roomID)] 수신: \(message)")
                self.onMessageReceived?(message)
            }
        }

        socket?.on(clientEvent: .disconnect) { data, ack in
            print("🔌 [\(self.roomID)] 소켓 연결 종료")
        }
    }
    
}

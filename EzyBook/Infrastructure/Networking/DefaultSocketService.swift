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
    private let keyChain: KeyChainTokenStorage
    private var isConnected: Bool = false
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    
    var onMessageReceived: ((ChatMessageEntity) -> Void)?
    var onConnect: (() -> Void)?
    
    init(roomID: String, keyChain: KeyChainTokenStorage) {
        self.roomID = roomID
        self.keyChain = keyChain
    }
    
    func connect() {
        guard !isConnected else { return }
        
        
        let strURL = APIConstants.baseURL
        let url = URL(string: strURL)!
        let namespace = "/chats-" + roomID

        guard let accessToken = keyChain.loadToken(key: KeychainKeys.accessToken) else { return }
        let headers: [String: String] = [
            "Authorization": accessToken,
            "SeSACKey": APIConstants.apiKey
        ]
        self.manager = SocketManager(
            socketURL: url,
            config: [
                .log(true),
                .compress,
                .extraHeaders(headers)
            ]
        )

        socket = self.manager?.socket(forNamespace: namespace)
        
        
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
            
            /// 연결이 되면 외부 콜백
            self.onConnect?()
        }
        socket?.on("chat") { dataArray, ack in
            guard let raw = dataArray.first else {
                //에러 처리 필요
                print("⚠️ [chat] 이벤트 수신 실패: dataArray가 비어 있음")
                return
            }

            guard JSONSerialization.isValidJSONObject(raw),
                  let data = try? JSONSerialization.data(withJSONObject: raw),
                  let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("⚠️ [chat] JSON 파싱 실패: \(raw)")
                //에러 처리 필요
                return
            }

            guard let message = ChatMessageEntity.from(dict: dict) else {
                print("⚠️ [chat] ChatMessageEntity 파싱 실패: \(dict)")
                return
            }

            self.onMessageReceived?(message)
        }
        

        socket?.on(clientEvent: .disconnect) { data, ack in
            print("🔌 [\(self.roomID)] 소켓 연결 종료")
        }
    }
    
    deinit {
        print(#function, "테스트")
    }
}

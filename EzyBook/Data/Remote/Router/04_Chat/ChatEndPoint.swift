//
//  ChatEndPoint.swift
//  EzyBook
//
//  Created by youngkyun park on 6/25/25.
//

import Foundation

enum ChatEndPoint: APIEndPoint {

    case makeChat //채팅방 생성
    case lookUpChatRoomList // 채팅방 목록 조회
    case sendChat(id: String) //채팅 보내기
    case lookUpChatList(id: String) //채팅내역 목록 조회
    case uploadChatFiles(id: String) // 채팅방 파일 업로드

    
    var path: String {
        switch self {
        case .makeChat, .lookUpChatRoomList:
            return "/v1/chats"
        case .sendChat(let id), .lookUpChatList(let id):
            return "/v1/chats/\(id)"
        case .uploadChatFiles(let id):
            return "/v1/chats/\(id)/files"
        }
    }

}

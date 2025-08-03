//
//  ChatRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import Foundation
import Alamofire
import SwiftUI

// MARK:  Get
enum ChatRequest {
    
    enum Get: GetRouter {
        case lookUpChatRoomList // 채팅방 목록 조회
        case lookUpChatList(id: String, dto: ChatListRequestDTO) //채팅내역 목록 조회
        
        var requiresAuth: Bool {
            true
        }
        
        var endpoint: URL? {
            switch self {
            case .lookUpChatRoomList:
                ChatEndPoint.lookUpChatRoomList.requestURL
            case .lookUpChatList(let id, _):
                ChatEndPoint.lookUpChatList(id: id).requestURL
            }
        }
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
            
        }
        
        var parameters: Parameters? {
            switch self {
            case .lookUpChatRoomList:
                return nil
            case .lookUpChatList(_, let dto):
                if let next = dto.next {
                    return ["next" : next]
                } else {
                    return nil
                }
                
            }
        }
        
    }
}


// MARK:  Post
extension ChatRequest {
    
    enum Post: PostRouter {
        case makeChat(dto: ChatRoomLookUpRequestDTO) //채팅방 생성
        case sendChat(roomId: String, dto: ChatSendMessageRequestDTO) //채팅 보내기
        
        var requiresAuth: Bool {
            true
        }
        
        var endpoint: URL? {
            switch self {
            case .makeChat:
                ChatEndPoint.makeChat.requestURL
            case .sendChat(let roomId, _):
                ChatEndPoint.sendChat(id: roomId).requestURL
            }
            
        }
        
        var requestBody: Encodable? {
            switch self {
            case .makeChat(let dto):
                return dto
            case .sendChat(_, let dto):
                return dto
            }
        }
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
            
        }
    }
    
    
}


//// 채팅방 파일 업로드

// MARK: MultiPart
extension ChatRequest {
    
    enum Multipart: MultipartRouter {
        
        
        
        case uploadChatFiles(id: String, image: [UIImage])
        
        var requiresAuth: Bool {
            return false
        }
        
        var endpoint: URL? {
            switch self {
            case .uploadChatFiles(let id, _):
                return ChatEndPoint.uploadChatFiles(id: id).requestURL
            }
        }
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
        }
        
        private var compressedImages: [Data] {
            switch self {
            case .uploadChatFiles(_, let images):
                return images.compactMap { $0.compressedJPEGData(maxSizeInBytes: 1_000_000) }
            }
        }
        
        var isEffectivelyEmpty: Bool {
            switch self {
            case .uploadChatFiles(let id, let image):
                return compressedImages.isEmpty
            }
        }
        
        var multipartFormData: ((MultipartFormData) -> Void)? {
            switch self {
            case .uploadChatFiles(_, let images):
                return { form in
                    for (index, data) in compressedImages.enumerated() {
                        form.append(
                            data,
                            withName: "files",
                            fileName: "chat\(index).jpg",
                            mimeType: "image/jpeg"
                        )
                        
                    }
                }
            }
        }
        
    }
}

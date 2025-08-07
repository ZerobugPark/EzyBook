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
        
        case uploadChatImages(id: String, image: [UIImage])
        case uploadChatFile(id: String, file: URL)
        
        var requiresAuth: Bool {
            return false
        }
        
        var endpoint: URL? {
            switch self {
            case .uploadChatImages(let id, _), .uploadChatFile(let id, _):
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
            case .uploadChatImages(_, let images):
                return images.compactMap { $0.compressedJPEGData(maxSizeInBytes: 1_000_000) }
            default:
                return []
            }
        }
        
        private var compressedFile: Data? {
            switch self {
            case .uploadChatFile(_, let file):
                // Debug: check file existence
                let exists = FileManager.default.fileExists(atPath: file.path)
                print("Uploading file at path: \(file.path), exists: \(exists)")
                do {
                    let data = try Data(contentsOf: file)
                    print("Read file data, size: \(data.count) bytes")
                    return data
                } catch {
                    print("Error reading file data: \(error)")
                    return nil
                }
            default:
                return nil
            }
        }
        
        /// nil이거나 사이즈가 크거나
        var isEffectivelyEmpty: Bool {
            switch self {
            case .uploadChatImages:
                return compressedImages.isEmpty
            case .uploadChatFile:
                if let compressedFile {
                    if compressedFile.count > 5 * 1_024 * 1_024 {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return true
                }
                
            }
        }
        
        var multipartFormData: ((MultipartFormData) -> Void)? {
            switch self {
            case .uploadChatImages:
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
            case .uploadChatFile:
                return { form in
                    form.append(
                        compressedFile ?? Data(),
                        withName: "files",
                        fileName: "document.pdf",
                        mimeType: "application/pdf"
                    )
                }
            }
            
        }
    }
}

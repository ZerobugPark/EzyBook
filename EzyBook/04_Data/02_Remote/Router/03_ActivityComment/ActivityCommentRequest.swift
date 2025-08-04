//
//  ActivityCommentRequest.swift
//  EzyBook
//
//  Created by youngkyun park on 8/4/25.
//

import Foundation
import Alamofire

// MARK:  Post
struct ActivityCommentRequest {
    
    enum Post: PostRouter {
        case writeComment(postID: String, parentID: String?, content: String ) // 포스트 파일 업로드
        
     
        var requiresAuth: Bool {
            true
        }
        
        var endpoint: URL? {
            switch self {
            case .writeComment(let id, _, _):
                ActivityCommentEndPoint.writeComment(postID: id).requestURL
            }
        }
        
  
        var requestBody: Encodable? {
            switch self {
            case let .writeComment(_, parentID, content):
                return [
                     "parent_comment_id": parentID,
                     "content": content,
                ]
            }
        }
        
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
            
        }
    }
    
    
}

// MARK: Put
extension ActivityCommentRequest {
    
    enum Put: PutRouter {
        
        case modifyComment(postID: String, commentID: String, content: String) // 게시글 수정
        
        var requiresAuth: Bool {
            return true
        }
        
        var endpoint: URL? {
            switch self {
            case let .modifyComment(postID,commentID, _):
                ActivityCommentEndPoint.modifyComment(postID: postID, commentID: commentID).requestURL
            }
        }
        
        var requestBody: Encodable? {
            switch self {
            case let .modifyComment(_, _ , content):
                return [
                    "content": content,
               ]
            }
        }
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
        }

    }
    
}


// MARK: Delete
extension ActivityCommentRequest {
    
    enum Delete: DeleteRouter {
        
        case deleteComment(postID: String, commentID: String) // 게시글 삭제
        
        var requiresAuth: Bool {
            return true
        }
        
        var endpoint: URL? {
            switch self {
            case let .deleteComment(postID,commentID):
                ActivityCommentEndPoint.deleteComment(postID: postID, commentID: commentID).requestURL
            }
        }
        
        var requestBody: Encodable? {
            switch self {
            case .deleteComment:
                return nil
            }
        }
        
        var headers: HTTPHeaders {
            [
                "SeSACKey": APIConstants.apiKey
            ]
        }

    }
    
}

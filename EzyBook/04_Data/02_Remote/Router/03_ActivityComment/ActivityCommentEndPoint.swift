//
//  ActivityCommentEndPoint.swift
//  EzyBook
//
//  Created by youngkyun park on 8/4/25.
//

import Foundation


enum ActivityCommentEndPoint: APIEndPoint {

    case writeComment(postID: String) // 포스트 파일 업로드
    case modifyComment(postID: String, commentID: String) // 댓글 수정
    case deleteComment(postID: String, commentID: String) // 댓글 삭제
    

    
    /// Path와 Query 기준은 뭘까? (Answered by Gpt)
    /// path:    어떤 리소스에 접근할지를 명확히 지정할 때 (ID, 고정된 리소스 구조)
    /// query:    검색, 필터링, 정렬, 페이지네이션 등 추가적인 옵션일 때
    
    var path: String {
        switch self {
        case .writeComment(let postID):
            return "/v1/posts/\(postID)/comments"
        case let .modifyComment(postID, commentID):
            return "/v1/posts/\(postID)/comments/\(commentID)"
        case let .deleteComment(postID, commentID):
            return "/v1/posts/\(postID)/comments/\(commentID)"
        }
    }

}

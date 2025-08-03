//
//  ActivityPostEndPoint.swift
//  EzyBook
//
//  Created by youngkyun park on 8/2/25.
//

import Foundation

enum ActivityPostEndPoint: APIEndPoint {

    case postFiles // 포스트 파일 업로드
    case writePost //게시글 작성
    case postLookup // 위치 기반 게시글 조회
    case postSearch // 게시글 검색 검색
    case detailPost(postID: String) // 상세조회
    case modifyPost(postID: String) // 게시글 수정
    case deletePost(postID: String) // 게시글 삭제
    case postKeep(postID: String) //게시글 킵/킵취소
    case writtenPost(userID: String) //내가 작성한 게시글
    case likedPosts // 내가 킵한 액티비티 리스트

    
    /// Path와 Query 기준은 뭘까? (Answered by Gpt)
    /// path:    어떤 리소스에 접근할지를 명확히 지정할 때 (ID, 고정된 리소스 구조)
    /// query:    검색, 필터링, 정렬, 페이지네이션 등 추가적인 옵션일 때
    
    var path: String {
        switch self {
        case .postFiles:
            return "/v1/posts/files"
        case .writePost:
            return "/v1/posts"
        case .postLookup:
            return "/v1/posts/geolocation"
        case .postSearch:
            return "/v1/posts/search"
        case .detailPost(let id), .modifyPost(let id), .deletePost(let id):
            return "/v1/posts/\(id)"
        case .postKeep(let id):
            return "/v1/posts/\(id)/like"
        case .writtenPost(let id):
            return "/v1/posts/users/\(id)"
        case .likedPosts:
            return "/v1/posts/likes/me"
        }
    }

}

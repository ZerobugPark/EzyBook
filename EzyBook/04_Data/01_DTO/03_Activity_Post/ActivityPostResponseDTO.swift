//
//  ActivityPostResponseDTO.swift
//  EzyBook
//
//  Created by youngkyun park on 8/1/25.
//

import Foundation



// MARK: 게시글 조회
struct PostSummaryPaginationResponseDTO: Decodable, EntityConvertible {
    
    let data: [PostSummaryResponseDTO]
    let nextCursor: String
    
    private enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}
    
struct PostSummaryResponseDTO: Decodable, EntityConvertible {
    let postID: String
    let country: String
    let category: String
    let title: String
    let content: String
    let activity: ActivitySummaryResponseDTO_Post?
    let geolocation: Geolocation
    let creator: UserInfoResponseDTO
    let files: [String]
    let isLike: Bool
    let likeCount: Int
    let createdAt: String
    let updatedAt: String
    
    private enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case country
        case category
        case title
        case content
        case activity
        case geolocation
        case creator
        case files
        case isLike = "is_like"
        case likeCount = "like_count"
        case createdAt
        case updatedAt
        
    }
    
}

// MARK: 게시글 타이틀 검색

struct PostSummaryListResponseDTO: Decodable, EntityConvertible {
    let data: [PostSummaryResponseDTO]
}


/// 게시글 킵/ 킵 취소 작업 후 상태
struct PostKeepResponseDTO: Decodable, EntityConvertible {
    let likeStatus: Bool  // 현재 게시글에 대한 사용자의 킵 상태 (즉 킵을 하면 true가 리턴)
    
    enum CodingKeys: String, CodingKey {
        case likeStatus = "like_status"
    }
}



// MARK: 게시글 작성 및 상세 조회
struct PostResponseDTO: Decodable, EntityConvertible {
    let postID: String
    let country: String
    let category: String
    let title: String
    let content: String
    let activity: ActivitySummaryResponseDTO_Post?
    let geolocation: Geolocation
    let creator: UserInfoResponseDTO
    let files: [String]
    let isLike: Bool
    let likeCount: Int
    let comments: [CommentResponseDTO]
    let createdAt: String
    let updatedAt: String
    
    private enum CodingKeys: String, CodingKey {
        case postID = "post_id"
        case country
        case category
        case title
        case content
        case activity
        case geolocation
        case creator
        case files
        case isLike = "is_like"
        case likeCount = "like_count"
        case comments
        case createdAt
        case updatedAt
        
    }
}


struct Geolocation: Decodable {
    let longitude: Float
    let latitude: Float
}


struct CommentResponseDTO: Decodable {
    let commentID: String
    let content: String
    let createdAt: String
    let creator: UserInfoResponseDTO
    let replies: [ReplyResponseDTO]
    
    private enum CodingKeys: String, CodingKey {
        case commentID = "comment_id"
        case content
        case createdAt
        case creator
        case replies
        
    }
    
}


struct ReplyResponseDTO: Decodable, EntityConvertible {
    let commentID: String
    let content: String
    let createdAt: String
    let creator: UserInfoResponseDTO
    
    private enum CodingKeys: String, CodingKey {
        case commentID = "comment_id"
        case content
        case createdAt
        case creator
  
    }
}


struct FileResponseDTO: Decodable, EntityConvertible {
    let files: [String]
}

/// 코메트 삭제
struct EmptyDTO: Decodable, EntityConvertible { } 

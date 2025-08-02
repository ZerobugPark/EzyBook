//
//  03_ActivityPostResponseMapper.swift
//  EzyBook
//
//  Created by youngkyun park on 8/2/25.
//

import Foundation

extension PostSummaryPaginationResponseDTO {
    
    func toEntity() -> PostSummaryPaginationEntity {
        PostSummaryPaginationEntity(dto: self)
    }
}

extension PostSummaryResponseDTO {
    
    func toEntity() -> PostSummaryEntity {
        PostSummaryEntity(dto: self)
    }
}

extension PostSummaryListResponseDTO {
    func toEntity() -> [PostSummaryEntity] {
        data.map { PostSummaryEntity(dto: $0) }
    }
}

extension PostKeepResponseDTO {
    func toEntity() -> PostKeepEntity {
        PostKeepEntity(likeStatus: self.likeStatus)
    }
}


extension PostResponseDTO {
    func toEntity() -> PostEntity {
        PostEntity(dto: self)
    }
}

extension CommentResponseDTO {
    func toEntity() -> CommentEntity {
        CommentEntity(dto: self)
    }
}

extension ReplyResponseDTO {
    func toEntity() -> ReplyEntity {
        ReplyEntity(dto: self)
    }
}

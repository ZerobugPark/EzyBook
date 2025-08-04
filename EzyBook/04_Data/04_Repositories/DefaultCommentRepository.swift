//
//  DefaultCommentRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 8/4/25.
//

import Foundation


final class DefaultCommentRepository: WriteCommentRepository, DeleteCommentRepository  {
    
    
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    
    func requestWriteCommnet(_ postID: String, _ parentID: String?, _ content: String) async throws  ->  ReplyEntity {
        
        let router = ActivityCommentRequest.Post.writeComment(postID: postID, parentID: parentID, content: content)
        
        let data = try await networkService.fetchData(dto: ReplyResponseDTO.self, router)
        
        return data.toEntity()
    }
    
    func requestDeleteCommnet(_ postID: String, _ commentID: String) async throws {
        
        let router = ActivityCommentRequest.Delete.deleteComment(postID: postID, commentID: commentID)
        
        let _ = try await networkService.fetchData(dto: EmptyDTO.self, router)
        
    }
} 

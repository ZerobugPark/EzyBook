//
//  DefaultCommentRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 8/4/25.
//

import Foundation


final class DefaultCommentRepository: WriteCommentRepository, DeleteCommentRepository, ModifyCommentRepository  {
    
    
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    
    func requestWriteComment(_ postID: String, _ parentID: String?, _ content: String) async throws  ->  ReplyEntity {
        
        let router = ActivityCommentRequest.Post.writeComment(postID: postID, parentID: parentID, content: content)
        
        let data = try await networkService.fetchData(dto: ReplyResponseDTO.self, router)
        
        return data.toEntity()
    }
    
    func requestDeleteComment(_ postID: String, _ commentID: String) async throws {
        
        let router = ActivityCommentRequest.Delete.deleteComment(postID: postID, commentID: commentID)
        
        let _ = try await networkService.fetchData(dto: EmptyDTO.self, router)
        
    }
    
    func requestModifyCommnet(_ postID: String, _ commnetID: String, _ text: String) async throws -> ReplyEntity {
        
        let router = ActivityCommentRequest.Put.modifyComment(postID: postID, commentID: commnetID, content: text)
        
        let data = try await networkService.fetchData(dto: ReplyResponseDTO.self, router)
        
        return data.toEntity()
        
        
    }
}

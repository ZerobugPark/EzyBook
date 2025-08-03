//
//  DefaultCommentRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 8/4/25.
//

import Foundation


final class DefaultCommentRepository: WriteCommentRepository  {
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    
    func requestWriteCommnet(_ postID: String, _ parentID: String?, _ content: String) async throws  ->  ReplyEntity {
        
        let router = ActivityCommentRequest.Post.writeComment(postID: postID, parentID: parentID, content: content)
        
        let data = try await networkService.fetchData(dto: ReplyResponseDTO.self, router)
        
        return data.toEntity()
    }
    
}

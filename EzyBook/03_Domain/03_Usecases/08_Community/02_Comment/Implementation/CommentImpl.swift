//
//  CommentImpl.swift
//  EzyBook
//
//  Created by youngkyun park on 8/4/25.
//

import Foundation


final class DefaultWriteCommentUseCase: WriteCommentUseCase {
    
    let repo: WriteCommentRepository
    
    init(repo: WriteCommentRepository) {
        self.repo = repo
    }
}

extension DefaultWriteCommentUseCase {
    
    func execute(postID: String, parentID: String?, content: String) async throws  ->  ReplyEntity {
        
        try await repo.requestWriteComment(postID, parentID, content)
    }
}


final class DefaultDeleteCommentUseCase: DeleteCommentUseCase {
    
    let repo: DeleteCommentRepository
    
    init(repo: DeleteCommentRepository) {
        self.repo = repo
    }
    
}

extension DefaultDeleteCommentUseCase {
    
    func execute(postID: String, commentID: String) async throws {
        
        try await repo.requestDeleteComment(postID, commentID)
    }
}

final class DefaultModifyCommnetUseCase: ModifyCommnetUseCase {
    
    let repo: ModifyCommentRepository
    
    init(repo: ModifyCommentRepository) {
        self.repo = repo
    }
    
}

extension DefaultModifyCommnetUseCase {
    
    func execute(postID: String, commnetID: String, text: String) async throws -> ReplyEntity {
        
        try await repo.requestModifyCommnet(postID, commnetID, text)
    }
}

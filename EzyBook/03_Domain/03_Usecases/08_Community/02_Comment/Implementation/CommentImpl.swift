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
        
        try await repo.requestWriteCommnet(postID, parentID, content)
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
        
        try await repo.requestDeleteCommnet(postID, commentID)
    }
}

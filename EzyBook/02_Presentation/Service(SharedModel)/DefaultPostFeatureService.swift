//
//  DefaultPostFeatureService.swift
//  EzyBook
//
//  Created by youngkyun park on 8/4/25.
//

import Foundation

final class DefaultPostFeatureService: PostFeatureService {
    
    let write: PostWriteServiceProtocol
    let delete: PostDeleteServiceProtocol
    
    init(write: PostWriteServiceProtocol, delete: PostDeleteServiceProtocol) {
        self.write = write
        self.delete = delete
    }
    
}

final class PostWriteService: PostWriteServiceProtocol {
    
    private let write: WriteCommentUseCase

    init(write: WriteCommentUseCase) {
        self.write = write
    }
    
    func writeComment(postID: String, parentID: String?, content: String) async throws -> ReplyEntity {
        try await write.execute(postID: postID, parentID: parentID, content: content)
    }
}

final class PostDeleteService: PostDeleteServiceProtocol {
    
    private let delete: DeleteCommentUseCase

    init(delete: DeleteCommentUseCase) {
        self.delete = delete
    }
    
    func deleteComment(postID: String, commentID: String) async throws  {
        try await delete.execute(postID: postID, commentID: commentID)
    }
}

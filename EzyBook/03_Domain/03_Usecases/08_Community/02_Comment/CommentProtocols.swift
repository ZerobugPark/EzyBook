//
//  CommentProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 8/4/25.
//

import Foundation

protocol WriteCommentUseCase {
    func execute(postID: String, parentID: String?, content: String) async throws  ->  ReplyEntity
}

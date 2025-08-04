//
//  03_PostCommnetRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 8/4/25.
//

import Foundation


protocol WriteCommentRepository {
    func requestWriteComment(_ postID: String, _ parentID: String?, _ content: String) async throws  ->  ReplyEntity

}


protocol DeleteCommentRepository {
    func requestDeleteComment(_ postID: String, _ commentID: String) async throws
}

protocol ModifyCommentRepository {
    func requestModifyCommnet(_ postID: String, _ commnetID: String, _ text: String) async throws -> ReplyEntity
}


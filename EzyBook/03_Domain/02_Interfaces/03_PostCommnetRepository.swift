//
//  03_PostCommnetRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 8/4/25.
//

import Foundation


protocol WriteCommentRepository {
    func requestWriteCommnet(_ postID: String, _ parentID: String?, _ content: String) async throws  ->  ReplyEntity
}

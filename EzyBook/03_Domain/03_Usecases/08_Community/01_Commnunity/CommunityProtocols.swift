//
//  CommunityProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 8/2/25.
//

import UIKit

protocol PostSummaryPaginationUseCase {
    func execute(query: ActivityPostLookUpQuery) async throws -> PostSummaryPaginationEntity
}


protocol PostSearchUseCase {
    func execute(title: String) async throws -> [PostSummaryEntity]
}

protocol PostImageUploadUseCase {
    func execute(images: [UIImage]) async throws -> FileResponseEntity
    func execute(videos: [Data]) async throws -> FileResponseEntity
}

protocol PostActivityUseCase {
    func execute(country: String, category: String, title: String, content: String, activity_id: String, latitude: Double, longitude: Double, files: [String]) async throws -> PostEntity
}


protocol UserWrittenPostListUseCase {
    func excute(userID: String) async throws -> [String]
}


protocol PostDetailUseCase {
    func execute(postID: String) async throws -> PostEntity
}



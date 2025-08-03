//
//  03_ActivityPostRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 8/2/25.
//

import UIKit

protocol PostSummaryPaginationRepository {
    func requestActivityPost(query: ActivityPostLookUpQuery)  async throws -> PostSummaryPaginationEntity
}

protocol PostSearchRepository {
    func reqeustSearchPost(_ title: String) async throws -> [PostSummaryEntity]
}


protocol PostUploadRepository {
    func requesPostUploadImages(_ images: [UIImage]) async throws -> FileResponseEntity
    
    func requesPostUploadVideos(_ videos: [Data]) async throws -> FileResponseEntity
}

protocol PostActivityRepository {
    func requestWirtePost(_ country: String, _ category: String, _ title: String, _ content: String, activity_id: String, latitude: Double, longitude: Double, _ files: [String]) async throws -> PostEntity
}

protocol WrittenPostListRepository {
    func requestWrittenPostList(id: String) async throws -> [String]
}


protocol PostDetailRepository {
    func requestPostDetail(postID: String) async throws -> PostEntity 
}

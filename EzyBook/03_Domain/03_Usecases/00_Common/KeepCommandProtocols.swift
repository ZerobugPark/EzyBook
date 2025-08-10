//
//  KeepCommandProtocols.swift
//  EzyBook
//
//  Created by youngkyun park on 8/10/25.
//

import Foundation


protocol PostLikeUseCase {
    func execute(postID: String, status: Bool) async throws -> PostKeepEntity
}


protocol PostLikeListUseCase {
    
    func execute(next: String?, limit: String) async throws -> PostSummaryPaginationEntity
}

protocol ActivityKeepCommandUseCase {
    func execute(id: String, stauts: Bool) async throws -> ActivityKeepEntity
}


protocol ActivityKeepListUseCase {
    func execute(next: String?, limit: String) async throws ->  ActivitySummaryListEntity
}


protocol MyPostUseCase {
    func execute(next: String?, limit: String, userID: String) async throws -> PostSummaryPaginationEntity
}

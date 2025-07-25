//
//  BannerUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 7/20/25.
//

import Foundation


protocol BannerInfoUseCase {
    func execute() async throws -> [BannerEntity]
}

// 배너 정보 가져오기
final class DefaultBannerInfoUseCase: BannerInfoUseCase {
    
    private let repo: BannerInfoRepository
    
    init(repo: BannerInfoRepository) {
        self.repo = repo
    }


}

extension DefaultBannerInfoUseCase {
    func execute() async throws -> [BannerEntity] {
        try await repo.rqeustBannerInfo()
    }
    
}

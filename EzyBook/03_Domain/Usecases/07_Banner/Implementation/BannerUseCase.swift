//
//  BannerUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 7/20/25.
//

import Foundation

// 배너 정보 가져오기
final class DefaultBannerInfoUseCase {
    
    private let repo: BannerInfoRepository
    
    init(repo: BannerInfoRepository) {
        self.repo = repo
    }
    
    
    func execute() async throws -> [BannerEntity] {
        
        do {
            return try await self.repo.rqeustBannerInfo()
        } catch  {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
            
        }
        
        
    }
    
}

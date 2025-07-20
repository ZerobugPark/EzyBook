//
//  07_BannerRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 7/20/25.
//

import Foundation

protocol BannerInfoRepository {
    
    func rqeustBannerInfo() async throws -> [BannerEntity]
}

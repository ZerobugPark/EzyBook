//
//  DefaultBannerRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 7/20/25.
//

import Foundation

struct DefaultBannerRepository: BannerInfoRepository {
 
    

    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    
    func rqeustBannerInfo() async throws -> [BannerEntity] {
        let router = BannerRequest.Get.banner
        
        let data = try await networkService.fetchData(dto: BannerListResponseDTO.self, router)
     
        return data.toEntity()
    }
    
}

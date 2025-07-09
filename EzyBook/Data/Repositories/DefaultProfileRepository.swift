//
//  DefaultProfileRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import Foundation


struct DefaultProfileRepository: ProfileLookupRepository, ProfileModifyRepository, ProfileSearchRepository {

    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    
    func requestProfileLookUp(_ router: UserRequest.Get) async throws -> ProfileLookUpEntity  {
        
        let data = try await networkService.fetchData(dto: ProfileLookUpResponseDTO.self, router)
        
        return data.toEntity()
        
    }
    
    func requestModifyProfile(_ router: UserRequest.Put) async throws -> ProfileLookUpEntity {
        
        let data = try await networkService.fetchData(dto: ProfileLookUpResponseDTO.self, router)
        
        return data.toEntity()
        
    }
    
    func requestSearchProfile(_ router: UserRequest.Get) async throws -> [UserInfoResponseEntity] {
        
        let data = try await networkService.fetchData(dto: UserInfoListResponseDTO.self, router)
        
        return data.toEntity()
        
    }
    
    
}

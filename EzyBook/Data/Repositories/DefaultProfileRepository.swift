//
//  DefaultProfileRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import Foundation

struct DefaultProfileRepository: ProfileLookupRepository, ProfileModifyRepository {
    
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
    
}

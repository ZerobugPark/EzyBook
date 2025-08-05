//
//  DefaultProfileRepository.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import Foundation


final class DefaultProfileRepository: ProfileLookupRepository, ProfileModifyRepository, ProfileSearchRepository {
  

    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    
    func requestProfileLookUp() async throws -> ProfileLookUpEntity  {
        
        let router = UserRequest.Get.profileLookUp
        
        let data = try await networkService.fetchData(dto: ProfileLookUpResponseDTO.self, router)
        
        return data.toEntity()
        
    }
    
    func requestModifyProfile(_ nick: String?, _ profileImage: String?, _ phoneNum: String?, _ introduce: String?) async throws -> ProfileLookUpEntity {
        
        let dto = ProfileModifyRequestDTO(
            nick: nick,
            profileImage: profileImage,
            phoneNum: phoneNum,
            introduction: introduce
        )
        
        let router = UserRequest.Put.profileModify(body: dto)
        
        let data = try await networkService.fetchData(dto: ProfileLookUpResponseDTO.self, router)
        
        return data.toEntity()
    }
    
    
    

    func requestSearchProfile(_ nick: String) async throws -> [UserInfoEntity] {
        
        let router = UserRequest.Get.searchUser(nick: nick)
        
        let data = try await networkService.fetchData(dto: UserInfoListResponseDTO.self, router)
        
        return data.toEntity()
        
    }
    
    
}

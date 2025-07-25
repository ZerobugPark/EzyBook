//
//  ProfileDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 7/24/25.
//

import Foundation

final class ProfileDIContainer {
    
    private let networkService: DefaultNetworkService
    private let commonDIContainer: CommonDIContainer
    
    init(networkService: DefaultNetworkService, commonDIContainer: CommonDIContainer) {
        self.networkService = networkService
        self.commonDIContainer = commonDIContainer
    }
    

    
}

// MARK: Maek Auth UseCase
extension ProfileDIContainer {
    
    
    // MARK: Make Bundle
    private func makeProfileUseCases() -> ProfileUseCases {
        ProfileUseCases(
            profileLookUp: makeProfileLookUpUseCase(),
            profileSearchUser: makeProfileSearchUseCase(),
            profileUploadImage: makeProfileUpLoadFileUseCase(),
            profileModify: makeProfileModifyUseCase()
        )
    }
    
    private func makeProfileLookUpUseCase() -> DefaultProfileLookUpUseCase {
        DefaultProfileLookUpUseCase(repo: commonDIContainer.makeProfileRepository())
    }
    
    private func makeProfileUpLoadFileUseCase() -> DefaultProfileUploadImageUseCase {
        DefaultProfileUploadImageUseCase(repo: commonDIContainer.makeUploadRepository())
    }
    
    private func makeProfileModifyUseCase() -> DefaultProfileModifyUseCase {
        DefaultProfileModifyUseCase(repo: commonDIContainer.makeProfileRepository())
    }
    
    private func makeProfileSearchUseCase() -> DefaultProfileSearchUseCase {
        DefaultProfileSearchUseCase(repo: commonDIContainer.makeProfileRepository())
    }
    
//    private func makeReviewWirteUseCase() -> DefaultReViewWriteUseCase {
//        DefaultReViewWriteUseCase(repo: reviewRepository)
//    }
    
//    private func makeReviewImageUpload() -> DefaultUploadReviewImages {
//        DefaultUploadReviewImages(repo: uploadRepository)
//    }
//    
    
}


// MARK: Data
extension ProfileDIContainer {
    
    private func makeAuthRepository() -> DefaultAuthRepository {
        DefaultAuthRepository(networkService: networkService)
    }
    
    private func makeSocialLoginService() -> DefaultSocialLoginService {
        DefaultSocialLoginService()
    }
}



// MARK: Make ViewModel
extension ProfileDIContainer {
    
    private func makeProfileViewModel() -> ProfileViewModel {
        
    }
    
}

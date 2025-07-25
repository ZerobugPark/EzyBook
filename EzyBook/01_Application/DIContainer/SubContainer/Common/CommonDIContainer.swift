//
//  CommonDIContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 7/24/25.
//

import Foundation


final class CommonDIContainer {
    
    private let imageLoader: ImageLoder
    private let imageCache: ImageCache
    private let networkService: DefaultNetworkService
    
    
    init(imageLoader: ImageLoder, imageCache: ImageCache, networkService: DefaultNetworkService) {
        self.imageLoader = imageLoader
        self.imageCache = imageCache
        self.networkService = networkService
    }

    
}



// MARK: Maek UseCase
extension CommonDIContainer {
    /// 프로필 조회
    func makeProfileSearchUseCase() -> ProfileLookUpUseCase {
        DefaultProfileLookUpUseCase(repo: makeProfileRepository())
    }
    
    /// 이미지 로드
    func makeImageLoadUseCase() -> ImageLoadUseCases {
        ImageLoadUseCases(
            originalImage: makeOriginalImageUseCase(),
            thumbnailImage: makeThumbnailImageUseCase()
        )
    }
    
    
    
    func makeOriginalImageUseCase() -> DefaultLoadImageOriginalUseCase {
        DefaultLoadImageOriginalUseCase(
            repo: makeLoadImageRepository()
        )
        
    }
    
    func makeThumbnailImageUseCase() -> DefaultThumbnailImageUseCase {
        DefaultThumbnailImageUseCase(
            repo: makeLoadImageRepository()
        )
    }
  

}


// MARK: Data
extension CommonDIContainer {
    
    private func makeProfileRepository() -> DefaultProfileRepository {
        DefaultProfileRepository(
            networkService: networkService
        )
    }
    
    /// 이미지 업로드
    private func makeUploadRepository() -> DefaultUploadFileRepository {
        DefaultUploadFileRepository(
            networkService: networkService
        )
    }
    
    func makeLoadImageRepository() -> DefaultLoadImageRepository {
        DefaultLoadImageRepository(
            imageLoader: imageLoader,
            imageCache: imageCache
        )
    }

}






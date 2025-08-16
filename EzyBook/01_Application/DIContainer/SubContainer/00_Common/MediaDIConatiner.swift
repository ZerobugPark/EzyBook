//
//  MediaDIConatiner.swift
//  EzyBook
//
//  Created by youngkyun park on 8/12/25.
//

import Foundation

protocol MediaFactory {
    func makeZoomableImageFullScreenViewModel() -> ZoomableImageFullScreenViewModel
    func makeVideoPlayerViewModel() -> VideoPlayerViewModel
    func makeRemoteImageViewModel(scale: CGFloat, path: String) -> RemoteImageViewModel
    
}

final class MediaDIContainer {
    private let imageLoader: ImageLoader
    private let videoLoader: VideoLoaderDelegate
    private let imageCache: ImageCache

    init(imageLoader: ImageLoader, videoLoader: VideoLoaderDelegate, imageCache: ImageCache) {
        self.imageLoader = imageLoader
        self.videoLoader = videoLoader
        self.imageCache = imageCache
    }

    func makeFactory() -> MediaFactory { Impl(container: self) }

    private final class Impl: MediaFactory {

        private let container: MediaDIContainer
        init(container: MediaDIContainer) { self.container = container }
 
                
        func makeRemoteImageViewModel(scale: CGFloat, path: String) -> RemoteImageViewModel {
            RemoteImageViewModel(
                imageLoadUseCases: container.makeImageLoadUseCase(),
                scale: scale,
                path: path
            )
        }
        
        func makeZoomableImageFullScreenViewModel() -> ZoomableImageFullScreenViewModel {
            ZoomableImageFullScreenViewModel(imageLoadUseCases: container.makeImageLoadUseCase())
        }

        func makeVideoPlayerViewModel() -> VideoPlayerViewModel {
            VideoPlayerViewModel(videoLoader: container.videoLoader)
        }
        
    }
}

extension MediaDIContainer {
    // MARK: - Private
    private func makeImageLoadUseCase() -> ImageLoadUseCases {
        ImageLoadUseCases(
            originalImage: makeOriginalImageUseCase(),
            thumbnailImage: makeThumbnailImageUseCase()
        )
    }

    private func makeLoadImageRepository() -> DefaultLoadImageRepository {
        DefaultLoadImageRepository(imageLoader: imageLoader, imageCache: imageCache)
    }

    private func makeOriginalImageUseCase() -> DefaultLoadImageOriginalUseCase {
        DefaultLoadImageOriginalUseCase(repo: makeLoadImageRepository())
    }

    private func makeThumbnailImageUseCase() -> DefaultThumbnailImageUseCase {
        DefaultThumbnailImageUseCase(repo: makeLoadImageRepository())
    }
}

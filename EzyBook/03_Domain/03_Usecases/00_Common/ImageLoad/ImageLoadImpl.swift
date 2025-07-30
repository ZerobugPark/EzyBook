//
//  ImageLoadImpl.swift
//  EzyBook
//
//  Created by youngkyun park on 7/25/25.
//

import SwiftUI


/// 원본 이미지
final class DefaultLoadImageOriginalUseCase {
    
    
    private let repo: LoadOriginalImage
    
    init(repo: LoadOriginalImage) {
        self.repo = repo
    }
    
    
}

extension DefaultLoadImageOriginalUseCase {
    
    func execute(path: String) async throws -> UIImage {
        try await repo.loadOriginalImage(from: path)
    }
    
}


/// 원본 이미지
final class DefaultThumbnailImageUseCase {
    
    
    private let repo: LoadThumbnailImage
    
    init(repo: LoadThumbnailImage) {
        self.repo = repo
    }
    
    
}

extension DefaultThumbnailImageUseCase {
    
    func execute(path: String, scale: CGFloat) async throws -> UIImage {
        try await repo.loadMediaPreview(from: path, scale: scale)
    }
    
}

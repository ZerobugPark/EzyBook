//
//  DefaultLoadImageUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/26/25.
//

import SwiftUI

/// 나중에 추상화 필요, 캐시 관련
struct DefaultLoadImageUseCase {
    
    private let imageLoader: ImagerLoader
    
    init(imageLoader: ImagerLoader) {
        self.imageLoader = imageLoader
    }
    
    func execute(_ path: String, scale: CGFloat = 0.0, isOriginal: Bool = false) async throws -> UIImage {
        do {
            if isOriginal {
                let image = try await imageLoader.loadOriginalImage(from: path)
                return image
            } else {
                let image = try await imageLoader.loadMediaPreview(from: path, scale: scale)
                return image
            }
        } catch {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
    }
    
}

extension DefaultLoadImageUseCase {
    func clearCache() {
        imageLoader.imageCache.clearAll()
    }

    func cleanUpDiskCache() async {
        await imageLoader.imageCache.cleanUpDiskCache()
    }
}


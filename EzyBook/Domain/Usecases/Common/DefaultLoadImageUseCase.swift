//
//  DefaultLoadImageUseCase.swift
//  EzyBook
//
//  Created by youngkyun park on 5/26/25.
//

import SwiftUI


struct DefaultLoadImageUseCase {
    
    private let imageLoader: ImagerLoader
    
    init(imageLoader: ImagerLoader) {
        self.imageLoader = imageLoader
    }
    
    func execute(_ path: String, scale: CGFloat) async throws -> UIImage {
        do {
            let image = try await imageLoader.loadMediaPreview(from: path, scale: scale)
            return image
        } catch {
            if let apiError = error as? APIError {
                throw apiError
            } else {
                throw APIError.unknown
            }
        }
    }
    
}


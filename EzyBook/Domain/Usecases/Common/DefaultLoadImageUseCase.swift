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
    
    func execute(_ path: String, scale: CGFloat, completionHandler: @escaping (Result<UIImage, APIError>) -> Void) {
        Task {
            do {
                let image = try await imageLoader.loadImage(from: path, scale: scale)
                await MainActor.run {
                    completionHandler(.success(image))
                }
            } catch {
                let resolvedError: APIError
                if let apiError = error as? APIError {
                    resolvedError = apiError
                } else {
                    resolvedError = .unknown
                }
                
                completionHandler(.failure(resolvedError))
            }
            
        }
    }
    
}


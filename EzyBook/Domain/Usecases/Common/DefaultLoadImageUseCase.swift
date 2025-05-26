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
    
    
    func execute(_ path: String, completionHandler: @escaping (Result <UIImage, APIError>) -> Void) {
        
        Task {
            do {
                let data = try await imageLoader.loadImage(from: path)
                
                guard let image = UIImage(data: data!) else {
                    let fallback = UIImage(named: "star")!
                    return completionHandler(.success(fallback))
                }
                
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
                await MainActor.run {
                    completionHandler(.failure(resolvedError))
                }

            }
        }

    }
    
    
    
}

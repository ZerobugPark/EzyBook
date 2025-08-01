//
//  RemoteImageViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 7/31/25.
//

import SwiftUI
import Combine


final class RemoteImageViewModel: ViewModelType {
    
    private let imageLoadUseCases: ImageLoadUseCases
    private let scale: CGFloat
    private let path: String
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    
    init(
        imageLoadUseCases: ImageLoadUseCases,
        scale: CGFloat,
        path: String
    ) {
        self.imageLoadUseCases = imageLoadUseCases
        self.scale = scale
        self.path = path
        transform()
        loadInitialImage(path)
    }
    
}

extension RemoteImageViewModel {
    
    struct Input { }
    
    struct Output {
        
        var image: UIImage? = nil
    }
    
    func transform() { }
    

}

extension RemoteImageViewModel {
    
    
    // MARK: Order List Loading (SRP-refactored)
    /// Handles the initial loading of the order list, showing/hiding loading indicator.
    ///
    
    private func loadInitialImage(_ path: String) {
        Task {
            guard !Task.isCancelled else {
                print("⚠️ Task cancelled for \(path)")
                return
            }
            
            await performLoadImage(path)
        }
    }
    
    private func performLoadImage(_ path: String) async {
        do {
            let image = try await requestThumbnailImage(path)
            
            await MainActor.run {
                
                output.image = image
            }
            
        } catch {
            await MainActor.run {
                
                output.image = UIImage(systemName: "star.fill")
            }
        }
    }
    
    /// 이미지 로드 함수
    private func requestThumbnailImage(_ path: String) async throws -> UIImage {
        
        return try await imageLoadUseCases.thumbnailImage.execute(path: path, scale: scale)
        
    }

}



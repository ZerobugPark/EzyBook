//
//  ZoomableImageFullScreenViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/8/25.
//

import SwiftUI
import Combine

final class ZoomableImageFullScreenViewModel: ViewModelType {

    
    var input = Input()
    private let imageLoader: DefaultLoadImageUseCase
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    init(imageLoader: DefaultLoadImageUseCase) {
        self.imageLoader = imageLoader
        transform()
    }
    
    
}

// MARK: Input/Output
extension ZoomableImageFullScreenViewModel {
    
    struct Input { }
    
    struct Output {
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
        var image: UIImage? = nil
      
    }
    
    func transform() { }
    
    private func hadleImageView(with path: String) {
        
        Task {
            do {
                let image = try await requestThumbnailImage(path)
                await MainActor.run {
                    output.image = image
                }
                
            } catch let error as APIError {
                await MainActor.run {
                    print("d에러 발생 에러 발생")
                    output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
                }
            }
            
        }
    }

    
    private func requestThumbnailImage(_ path: String) async throws -> UIImage {
        
        return try await imageLoader.execute(path, isOriginal: true)
        
    }
    
    
}

// MARK: Action
extension ZoomableImageFullScreenViewModel {
    
    enum Action {
        case onAppearRequested(path: String)
    }
    
    func action(_ action: Action) {
        switch action {
        case .onAppearRequested(let path):
            hadleImageView(with: path)
                  
        }
    }
    
    
}



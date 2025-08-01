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
    private let imageLoadUseCases: ImageLoadUseCases
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    init(imageLoadUseCases: ImageLoadUseCases) {
        self.imageLoadUseCases = imageLoadUseCases
        transform()
    }
    
    
}

// MARK: Input/Output
extension ZoomableImageFullScreenViewModel {
    
    struct Input { }
    
    struct Output {
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        var image: UIImage? = nil
      
    }
    
    func transform() { }
    
    
    private func handleLoadImage(with path: String) {
        Task {
            await performImageLoad(path)
        }
    }

    
    
    private func performImageLoad(_ path: String) async {
        do {
            let image = try await requestOriginalImage(path)
            await MainActor.run {
                output.image = image
            }
        } catch {
            await handleError(error)
        }
    }

    @MainActor
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            output.presentedMessage = DisplayMessage.error(code: apiError.code, msg: apiError.userMessage)
        } else {
            output.presentedMessage = DisplayMessage.error(code: -1, msg: error.localizedDescription)
        }
    }


    
    //TODO: 이것도 나중에 공통 모듈로 뺄 수 있을거 같다.
    private func requestOriginalImage(_ path: String) async throws -> UIImage {
        return try await imageLoadUseCases.originalImage.execute(path: path)
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
            handleLoadImage(with: path)
                  
        }
    }
    
    
}

// MARK: Alert 처리
extension ZoomableImageFullScreenViewModel: AnyObjectWithCommonUI {
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    var isSuccessMessage: Bool { output.presentedMessage?.isSuccess ?? false }
    

}

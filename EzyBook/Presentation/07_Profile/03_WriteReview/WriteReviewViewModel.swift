//
//  WriteReviewViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/20/25.
//

import SwiftUI
import PhotosUI
import Combine

final class WriteReviewViewModel: ViewModelType {
    
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    private var scale: CGFloat = 0
    
    init(
    ) {
        transform()
    }
    
}

extension WriteReviewViewModel {
    
    struct Input {
        var reviewText = ""
    
    }
    
    struct Output {
        var isLoading = false
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
        
        var orderList: [OrderList] = []
    }
    
    func transform() { }
    

    

 
    
    private func handleResetError() {
        output.presentedError = nil
    }
    
    private func handleUpdateScale(_ scale: CGFloat) {
        self.scale = scale
    }
    
}

// MARK: Action
extension WriteReviewViewModel {
    
    enum Action {
        case updateScale(scale: CGFloat)
        case resetError
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .updateScale(let scale):
            handleUpdateScale(scale)
        case .resetError:
            handleResetError()
            
        }
    }
    
    
}



//
//  ProfileSupplementaryViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/18/25.
//

import SwiftUI
import Combine



/// 결제 영수증 등 부가적인 뷰모델
final class ProfileSupplementaryViewModel: ViewModelType {
    
    private let orderListUseCase: DefaultOrderListLookupUseCase
        
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    init(orderListUseCase: DefaultOrderListLookupUseCase) {

        self.orderListUseCase = orderListUseCase
        transform()
    }
    
    
}

// MARK: Input/Output
extension ProfileSupplementaryViewModel {
    
    struct Input {  }
    
    struct Output {
        var orderList: [OrderEntity] = []
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
    }
    
    func transform() {}
    
    
    private func handleRequestOrderList() {
        
        Task {
            do {
                let data = try await orderListUseCase.execute()
                await MainActor.run {
                    output.orderList = data
                    dump(data)
                }
            } catch let error as APIError {
                await MainActor.run {
                    output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
                }
            }
        }
    }
    
    private func handleResetError() {
        output.presentedError = nil
    }
    
    
}


// MARK: Action
extension ProfileSupplementaryViewModel {
    
    enum Action {
        case onAppearRequested
        case resetError
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .onAppearRequested:
            handleRequestOrderList()
        case .resetError:
            handleResetError()
        }
    }
    
    
}


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
    
    private let orderListUseCase: OrderListLookUpUseCase
        
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    init(orderListUseCase: OrderListLookUpUseCase) {

        self.orderListUseCase = orderListUseCase
        transform()
    }
    
    
}

// MARK: Input/Output
extension ProfileSupplementaryViewModel {
    
    struct Input {  }
    
    struct Output {
        var orderList: [OrderEntity] = []
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
    }
    
    func transform() {}
        
    @MainActor
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            output.presentedMessage = DisplayMessage.error(code: apiError.code, msg: apiError.userMessage)
        } else {
            output.presentedMessage = DisplayMessage.error(code: -1, msg: error.localizedDescription)
        }
    }
    
}

// MARK: 주문내역
extension ProfileSupplementaryViewModel {
    
    private func handleOrderList() {
        
        Task {
           await performOrderListLoad()
        }
    }
    
    private func performOrderListLoad() async {
        
        do {
            let data = try await orderListUseCase.execute()
            await MainActor.run {
                output.orderList = data
            }
        } catch {
            await handleError(error)
        }
    }
        
        
        
        
}


// MARK: Action
extension ProfileSupplementaryViewModel {
    
    enum Action {
        case onAppearRequested
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .onAppearRequested:
            handleOrderList()
            
        }
    }
    
    
}



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
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
    }
    
    func transform() {}
    

    
    private func handleResetError() {
        output.presentedError = nil
    }
    
    
    @MainActor
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            output.presentedError = DisplayError.error(code: apiError.code, msg: apiError.userMessage)
        } else {
            output.presentedError = DisplayError.error(code: -1, msg: error.localizedDescription)
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
        case resetError
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .onAppearRequested:
            handleOrderList()
        case .resetError:
            handleResetError()
        }
    }
    
    
}

// MARK: Alert 처리
extension ProfileSupplementaryViewModel: AnyObjectWithCommonUI {
    
    var isShowingError: Bool { output.isShowingError }
    
    var presentedErrorTitle: String? { output.presentedError?.message.title }
    
    var presentedErrorMessage: String? { output.presentedError?.message.msg }
    
    var presentedErrorCode: Int?  { output.presentedError?.code }
    
    func resetErrorAction() { action(.resetError) }
    
    
    
}



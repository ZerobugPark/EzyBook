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
        handleInitialLoad()
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
        
        var userCommerceInfo: (price: Int, reward: Int) = (0, 0)
        
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
    
    private func handleInitialLoad() {
        Task {
            await performOrderListLoad()
            await MainActor.run {
                performUpdateUserData(output.orderList)
            }
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

// MARK: 가격 및 포인트 조회

private extension ProfileSupplementaryViewModel {
    
    func performUpdateUserData(_ data: [OrderEntity]) {
        let prcie = performCalcPoint(data)
        let point = performCalcPice(data)
        
        output.userCommerceInfo = (prcie, point)

        
    }
    
    func performCalcPoint(_ data: [OrderEntity]) -> Int {
        data.map { $0.totalPrice }.reduce(0, +)
    }
    
    func performCalcPice(_ data: [OrderEntity]) -> Int {
        data.map { $0.activity.pointReward ?? 0 }.reduce(0, +)
    }
    
}





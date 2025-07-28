//
//  PaymentViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/11/25.
//


import SwiftUI
import Combine

final class PaymentViewModel: ViewModelType {
    
    private let vaildationUseCase: PaymentValidationUseCase
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    init(vaildationUseCase: PaymentValidationUseCase) {
        
        self.vaildationUseCase = vaildationUseCase
        transform()
    }
    
    
}

// MARK: Input/Output
extension PaymentViewModel {
    
    struct Input {  }
    
    struct Output {
        var presentedError: DisplayMessage? = nil
    }
    
    func transform() {}
    

    
    private func handleValidateReceipt(_ impUid: String, _ merchantUid: String, completion: @escaping (DisplayMessage?) -> Void) {
        Task {
            await performValidateReceipt(impUid, merchantUid, completion: completion)
        }
    }

    private func performValidateReceipt(_ impUid: String, _ merchantUid: String, completion: @escaping (DisplayMessage?) -> Void) async {
        do {
            let data = try await vaildationUseCase.execute(impUid: impUid)
            await MainActor.run {
                if data.orderItem.orderCode != merchantUid {
                    let error = DisplayMessage.error(code: 0, msg: "결제는 성공했으나, merchant가 다름")
                    output.presentedError = error
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        } catch {
            await handleError(error)
            completion(output.presentedError)
        }
    }
    
    
    
    @MainActor
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            output.presentedError = DisplayMessage.error(code: apiError.code, msg: apiError.userMessage)
        } else {
            output.presentedError = DisplayMessage.error(code: -1, msg: error.localizedDescription)
        }
        
        
    }
    
}

// MARK: Action
extension PaymentViewModel {
    
    enum Action {
        case vaildation(impUid: String, merchantUid: String, completion: (DisplayMessage?) -> Void)
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case let .vaildation(impUid, merchantUid, completion):
            handleValidateReceipt(impUid, merchantUid, completion: completion)
        }
    }
    
    
}

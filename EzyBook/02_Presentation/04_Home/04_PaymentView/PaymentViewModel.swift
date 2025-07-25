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
    
    private var scale: CGFloat = 0
      
    init(vaildationUseCase: PaymentValidationUseCase) {

        self.vaildationUseCase = vaildationUseCase
        transform()
    }
    
    
}

// MARK: Input/Output
extension PaymentViewModel {
    
    struct Input {  }
    
    struct Output {
        var presentedError: DisplayError? = nil
    }
    
    func transform() {}
    
    
    private func handleRequestRecepit(_  impUid:  String, _ merchantUid: String) {
        Task {
            do {
                let data = try await vaildationUseCase.execute(impUid: impUid)
                await MainActor.run {
                    /// 이 조건이 가능한걸까?
                    if data.orderItem.orderCode != merchantUid {
                        output.presentedError = DisplayError.error(code: 0, msg: "결제는 성공했으나, merchant가 다름")
                    }
                }
            } catch let error as APIError {
                await MainActor.run {
                    output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
                }
            }
        }
    }
    
    
}

// MARK: Action
extension PaymentViewModel {
    
    enum Action {
        case vaildation(impUid: String, merchantUid: String)
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case let .vaildation(impUid, merchantUid):
            handleRequestRecepit(impUid, merchantUid)
        }
    }
    
    
}


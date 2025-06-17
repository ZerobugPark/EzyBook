//
//  PayMentViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/11/25.
//


import SwiftUI
import Combine

final class PayMentViewModel: ViewModelType {
    
    private let vaildationUseCase: DefaultPaymentValidationUseCase
        
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    private var scale: CGFloat = 0
      
    init(vaildationUseCase: DefaultPaymentValidationUseCase) {

        self.vaildationUseCase = vaildationUseCase
        transform()
    }
    
    
}

// MARK: Input/Output
extension PayMentViewModel {
    
    struct Input {  }
    
    struct Output {
        var presentedError: DisplayError? = nil
    }
    
    func transform() {}
    
    
    private func handleRequestRecepit(_  impUid:  String, _ merchantUid: String) {
        
        let dto = PaymentValidationDTO(impUid: impUid)
        
        Task {
            do {
                let data = try await vaildationUseCase.execute(dto: dto)
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


//// MARK: Action
extension PayMentViewModel {
    
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


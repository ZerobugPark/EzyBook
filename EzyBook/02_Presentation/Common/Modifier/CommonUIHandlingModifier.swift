//
//  CommonUIHandlingModifier.swift
//  EzyBook
//
//  Created by youngkyun park on 7/26/25.
//

import SwiftUI

// MARK: - Common UI Handling
struct CommonUIHandlingModifier<ViewModel: ObservableObject & AnyObjectWithCommonUI>: ViewModifier {
    @ObservedObject var viewModel: ViewModel
    var onConfirm: ((Int?, Bool) -> Void)? = nil // ✅ 성공 여부까지 전달
    
    func body(content: Content) -> some View {
        content
            .commonAlert(
                isPresented: Binding(
                    get: { viewModel.isShowingMessage },
                    set: { isPresented in
                        if !isPresented {
                            onConfirm?(
                                viewModel.presentedMessageCode,
                                viewModel.isSuccessMessage
                            )
                            viewModel.resetMessageAction()
                        }
                    }
                ),
                title: viewModel.presentedMessageTitle,
                message: viewModel.presentedMessageBody
            )
            
    }
}
protocol AnyObjectWithCommonUI {
    var isShowingMessage: Bool { get }
    var presentedMessageTitle: String? { get }
    var presentedMessageBody: String? { get }
    var presentedMessageCode: Int? { get }
    var isSuccessMessage: Bool { get }
    func resetMessageAction()
}

extension AnyObjectWithCommonUI {
    var isSuccessMessage: Bool {
        false
    }
    
    func resetMessageAction() {
        
    }
}



extension View {
    func withCommonUIHandling<ViewModel: ObservableObject & AnyObjectWithCommonUI>(
        _ viewModel: ViewModel,
        onConfirm: ((Int?, Bool) -> Void)?
    ) -> some View {
        self.modifier(CommonUIHandlingModifier(viewModel: viewModel, onConfirm: onConfirm))
    }
}

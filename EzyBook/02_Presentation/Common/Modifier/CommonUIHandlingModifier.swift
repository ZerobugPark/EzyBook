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
    var onConfirm: ((Int?) -> Void)? = nil
    
    func body(content: Content) -> some View {
        content
            .commonAlert(
                isPresented: Binding(
                    get: { viewModel.isShowingError },
                    set: { isPresented in
                        if !isPresented {
                            onConfirm?(viewModel.presentedErrorCode)
                            viewModel.resetErrorAction()
                        }
                    }
                ),
                title: viewModel.presentedErrorTitle,
                message: viewModel.presentedErrorMessage
            )
            .loadingOverlayModify(viewModel.isLoading)
    }
}

protocol AnyObjectWithCommonUI {
    var isShowingError: Bool { get }
    var presentedErrorTitle: String? { get }
    var presentedErrorMessage: String? { get }
    var isLoading: Bool { get }
    var presentedErrorCode: Int? { get }
    func resetErrorAction()
}

extension View {
    func withCommonUIHandling<ViewModel: ObservableObject & AnyObjectWithCommonUI>(
        _ viewModel: ViewModel,
        onConfirm: ((Int?) -> Void)? = nil
    ) -> some View {
        self.modifier(CommonUIHandlingModifier(viewModel: viewModel, onConfirm: onConfirm))
    }
}

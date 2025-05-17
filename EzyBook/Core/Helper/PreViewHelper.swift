//
//  PreViewHelper.swift
//  EzyBook
//
//  Created by youngkyun park on 5/17/25.
//

import SwiftUI

enum PreViewHelper {
    
    static let diContainer = DIContainer(
        networkManger: NetworkService(),
        decodingManger: ResponseDecoder()
    )
    
    static func makeLoginView(showModal: Binding<Bool> = .constant(false)) -> some View {
        LoginView(showModal: showModal)
            .environmentObject(diContainer)
    }
    
    static func makeCreateAccountView(selectedIndex: Binding<Int> = .constant(1)) -> some View {
        CreateAccountView(selectedIndex: selectedIndex, viewModel: diContainer.makeAccountViewModel())
    }
    
    static func makeEmailLoginView(selectedIndex: Binding<Int> = .constant(0)) -> some View {
        EmailLoginView(selectedIndex: selectedIndex)
            .environmentObject(diContainer)
    }
    
    static func makeLoginSignUpPagerView() -> some View {
        LoginSignUpPagerView()
            .environmentObject(diContainer)
    }
}

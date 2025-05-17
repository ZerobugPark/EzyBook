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
    
}

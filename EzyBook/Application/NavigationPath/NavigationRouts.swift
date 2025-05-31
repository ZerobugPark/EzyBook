//
//  NavigationRouts.swift
//  EzyBook
//
//  Created by youngkyun park on 5/22/25.
//

import SwiftUI

enum AuthRoute {
    case socialLogin
    case emailLogin
    
    
    @ViewBuilder
    func destinationView(container: DIContainer) -> some View {
        switch self {
        case .socialLogin:
            LoginView(viewModel: container.makeSocialLoginViewModel())
        case .emailLogin:
            LoginSignUpPagerView()
        }
    }
    
}

enum MainRoute {
    case homeView
    case emailLogin
    
    
    @ViewBuilder
    func destinationView(container: DIContainer) -> some View {
        switch self {
        case .homeView:
            LoginView(viewModel: container.makeSocialLoginViewModel())
        case .emailLogin:
            LoginSignUpPagerView()
        }
    }
    
}

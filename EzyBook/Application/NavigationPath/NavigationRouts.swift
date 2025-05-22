//
//  NavigationRouts.swift
//  EzyBook
//
//  Created by youngkyun park on 5/22/25.
//

import SwiftUI

enum AuthRoute {
    case socailLogin
    case emailLogin
    
    
    @ViewBuilder
    func destinationView(container: DIContainer) -> some View {
        switch self {
        case .socailLogin:
            LoginView(viewModel: container.makeSocialLoginViewModel())
        case .emailLogin:
            LoginSignUpPagerView()
        }
    }
    
}

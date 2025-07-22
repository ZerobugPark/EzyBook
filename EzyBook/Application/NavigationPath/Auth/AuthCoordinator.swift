//
//  AuthCoordinator.swift
//  EzyBook
//
//  Created by youngkyun park on 5/22/25.
//

import Foundation

import SwiftUI


final class AuthCoordinator: ObservableObject {
    
    @Published var path = NavigationPath()
    
    private let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func push(_ route: AuthRoute) {
        path.append(route)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    
    @ViewBuilder
    func destinationView(route: AuthRoute) -> some View {
        switch route {
        case .socialLogin:
            LoginView(coordinator: self, viewModel: self.container.loginDIContainer.makeSocialLoginViewModel())
        case .emailLogin:
            LoginSignUpPagerView(coordinator: self)
        }
    }
    
}

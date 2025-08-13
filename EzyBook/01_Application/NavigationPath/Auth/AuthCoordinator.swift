//
//  AuthCoordinator.swift
//  EzyBook
//
//  Created by youngkyun park on 5/22/25.
//

import Foundation

import SwiftUI


final class AuthCoordinator: ObservableObject {
    
    @Published var routeStack: [AuthRoute] = []
    
    private let factory: LoginFactory
    
    private lazy var loginViewModel = factory.makeSocialLoginViewModel()
  
    private var emailViewModel: EmailLoginViewModel?
    private var accountViewModel: CreateAccountViewModel?
    
    private func getEmailVM() -> EmailLoginViewModel {
        if let vm = emailViewModel { return vm }
        let vm = factory.makeEmailLoginViewModel()
        emailViewModel = vm
        return vm
    }

    private func getAccountVM() -> CreateAccountViewModel {
        if let vm = accountViewModel { return vm }
        let vm = factory.makeAccountViewModel()
        accountViewModel = vm
        return vm
    }
    
    
    init(factory: LoginFactory) {
        self.factory = factory
    }
    
}

extension AuthCoordinator {
    
    
    @ViewBuilder
    func rootView() -> some View {
        LoginView(coordinator: self, viewModel: self.loginViewModel)
    }
       
    func push(_ route: AuthRoute) {
        
        if case .emailLogin = route {
            if emailViewModel == nil { emailViewModel = factory.makeEmailLoginViewModel() }
            if accountViewModel == nil { accountViewModel = factory.makeAccountViewModel() }
          }
        
        
        routeStack.append(route)
    }

    func pop() {
        
        guard let last = routeStack.popLast() else { return }
        
        switch last {
        case .emailLogin:
            emailViewModel = nil
            accountViewModel = nil
        }
        
       
    }

    func popToRoot() {
        routeStack.removeAll()
    }

    
    @ViewBuilder
    func destinationView(route: AuthRoute) -> some View {
        switch route {
        case .emailLogin:
            LoginSignUpPagerView(
                coordinator: self,
                loginViewModel: getEmailVM(),
                accountViewModel: getAccountVM()
            )
        }
    }
    
}

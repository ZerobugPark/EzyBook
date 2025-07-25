//
//  AuthModelView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/22/25.
//

import SwiftUI

struct AuthCoordinatorView: View {
    
    @EnvironmentObject var container: DIContainer
    @StateObject var coordinator: AuthCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            LoginView(
                coordinator: coordinator, viewModel: container.loginDIContainer.makeSocialLoginViewModel()
            ).navigationDestination(for: AuthRoute.self) { route in
                coordinator.destinationView(route: route)
                
                
            }
        }
    }
}

#Preview {
    //AuthCoordinatorView()
}

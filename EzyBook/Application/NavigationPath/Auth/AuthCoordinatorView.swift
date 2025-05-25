//
//  AuthModelView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/22/25.
//

import SwiftUI

struct AuthCoordinatorView: View {
    
    @EnvironmentObject var auth: AuthModelObject
    @EnvironmentObject var container: DIContainer
    var body: some View {
        NavigationStack(path: $auth.path) {
            LoginView(
                viewModel: container.makeSocialLoginViewModel()
            ).navigationDestination(for: AuthRoute.self) { route in
                route.destinationView(container: container)
            }
        }
    }
}

#Preview {
    AuthCoordinatorView()
}

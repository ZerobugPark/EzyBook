//
//  ProfileViewCoordinatorView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

struct ProfileViewCoordinatorView: View {
    
    @EnvironmentObject var container: DIContainer
    @ObservedObject var coordinator: ProfileCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ProfileView(
                viewModel: container.makeProfileViewModel(),
                supplementviewModel: container.makeProfileSupplementaryViewModel(),
                coordinator: coordinator
            )
                .navigationDestination(for: ProfileRoute.self) { route in
                    coordinator.destinationView(route: route)
                }
        }
    }
}

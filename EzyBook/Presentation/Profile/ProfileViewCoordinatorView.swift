//
//  ProfileViewCoordinatorView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

struct ProfileViewCoordinatorView: View {
    
    @EnvironmentObject var container: DIContainer
    @StateObject var coordinator: ProfileCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ProfileView(coordinator: coordinator)
                .navigationDestination(for: ProfileRoute.self) { route in
                    coordinator.destinationView(route: route)
                }
        }
    }
}

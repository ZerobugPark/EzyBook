//
//  CommunityCoordinatorView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

struct CommunityCoordinatorView: View {
    
    @EnvironmentObject var container: DIContainer
    @StateObject var coordinator: CommunityCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            CommunityView(coordinator: coordinator)
                .navigationDestination(for: CommunityRoute.self) { route in
                    coordinator.destinationView(route: route)
                }
        }
    }
}


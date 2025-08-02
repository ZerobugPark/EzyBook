//
//  CommunityCoordinatorView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

struct CommunityCoordinatorView: View {
    
    @EnvironmentObject var container: AppDIContainer
    @ObservedObject var coordinator: CommunityCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            CommunityView(viewModel: container.communityDIContainer.makeCommunityViewModel(), coordinator: coordinator)
                .navigationDestination(for: CommunityRoute.self) { route in
                    coordinator.destinationView(route: route)
                }
        }
    }
}


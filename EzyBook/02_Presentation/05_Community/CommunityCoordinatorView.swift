//
//  CommunityCoordinatorView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

struct CommunityCoordinatorView: View {
    
    @ObservedObject var coordinator: CommunityCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.routeStack) {
            coordinator.rootView()
                .navigationDestination(for: CommunityRoute.self) { route in
                    coordinator.destinationView(route: route)
                }
        }
    }
}


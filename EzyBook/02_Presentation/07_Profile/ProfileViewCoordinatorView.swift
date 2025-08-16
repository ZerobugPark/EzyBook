//
//  ProfileViewCoordinatorView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

struct ProfileViewCoordinatorView: View {
        
    @ObservedObject var coordinator: ProfileCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.routeStack) {
            coordinator.rootView()
                .navigationDestination(for: ProfileRoute.self) { route in
                    coordinator.destinationView(route: route)
                }
        }
    }
}

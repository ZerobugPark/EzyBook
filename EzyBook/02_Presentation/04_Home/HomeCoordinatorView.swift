//
//  HomeCoordinatorView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/31/25.
//

import SwiftUI

struct HomeCoordinatorView: View {
    
    
    @EnvironmentObject var container: AppDIContainer
    @ObservedObject var coordinator: HomeCoordinator
    
    var body: some View {
        
        NavigationStack(path: $coordinator.routeStack) {
            coordinator.rootView()
                .navigationDestination(for: HomeRoute.self) { route in
                    coordinator.destinationView(route: route)
                }
        }
        
    }
}


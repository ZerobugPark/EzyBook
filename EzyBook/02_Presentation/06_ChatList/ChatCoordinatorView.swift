//
//  ChatCoordinatorView.swift
//  EzyBook
//
//  Created by youngkyun park on 7/10/25.
//

import SwiftUI

struct ChatCoordinatorView: View {
    
    @EnvironmentObject var container: AppDIContainer
    @ObservedObject var coordinator: ChatCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.rootView()
                .navigationDestination(for: ChatRoute.self) { route in
                    coordinator.destinationView(route: route)
                }
        }
    }
}


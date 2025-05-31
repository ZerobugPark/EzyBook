//
//  AppEntryView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import SwiftUI

struct AppEntryView: View {
    @EnvironmentObject var coordinator: CoordinatorContainer
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        
        if appState.isLoggedIn {
            MainTabView()
                .environmentObject(coordinator.makeHomeCoordinator())
        } else {
            AuthCoordinatorView()
                .environmentObject(coordinator.makeAuthCoordinator())
        }
        
    }
}

#Preview {
    AppEntryView()
}

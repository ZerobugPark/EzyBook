//
//  AppEntryView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/21/25.
//

import SwiftUI

struct AppEntryView: View {
    
    @EnvironmentObject var container: AppDIContainer
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        
        if appState.isLoggedIn {
            MainTabView(container: container)
        } else {
            AuthCoordinatorView(
                coordinator: AuthCoordinator(container: container.loginDIContainer)
            )
        }
        
    }
}

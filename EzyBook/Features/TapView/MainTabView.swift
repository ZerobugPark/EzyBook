//
//  MainTabView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI

struct MainTabView: View {
    
    enum Tab {
        case profile
        case settings
    }
    
    @State private var selectedTab: Tab = .profile
    
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ProfileView()
                .tabItem {
                    Image(selectedTab == .profile ? .tabBarProfileFill: .tabBarProfileEmpty)
                    
                    
                }
                .environmentObject(container)
                .tag(Tab.profile)
        }
    }
}

#Preview {
    MainTabView()
}

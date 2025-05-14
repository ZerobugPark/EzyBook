//
//  EzyBookApp.swift
//  EzyBook
//
//  Created by youngkyun park on 5/10/25.
//

import SwiftUI

@main
struct EzyBookApp: App {
    
    @StateObject var container = AppDIContainer().makeDIContainer()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(container)
        }
    }
}

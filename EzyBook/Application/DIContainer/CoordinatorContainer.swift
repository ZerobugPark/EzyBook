//
//  CoordinatorContainer.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import Foundation

final class CoordinatorContainer: ObservableObject {

    /// Coordinator
    private let authCoordinator = AuthCoordinator()
    private let homeCoordinator = HomeCoordinator()
    
    
    func makeAuthCoordinator() -> AuthCoordinator {
        authCoordinator
    }
    
    func makeHomeCoordinator() -> HomeCoordinator {
        homeCoordinator
    }

 
    
        
}


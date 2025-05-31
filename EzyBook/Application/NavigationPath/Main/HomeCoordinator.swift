//
//  MainModelObject.swift
//  EzyBook
//
//  Created by youngkyun park on 5/22/25.
//

import SwiftUI

final class HomeCoordinator: ObservableObject {
 
    @Published var path = NavigationPath()
    
    func push(_ route: AuthRoute) {
        path.append(route)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

}

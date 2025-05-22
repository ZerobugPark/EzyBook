//
//  AuthModelObject.swift
//  EzyBook
//
//  Created by youngkyun park on 5/22/25.
//

import Foundation

import SwiftUI


final class AuthModelObject: ObservableObject {
 
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

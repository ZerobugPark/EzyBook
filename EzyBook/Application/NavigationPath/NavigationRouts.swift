//
//  NavigationRouts.swift
//  EzyBook
//
//  Created by youngkyun park on 5/22/25.
//

import SwiftUI

enum AuthRoute {
    case socialLogin
    case emailLogin

}

enum HomeRoute: Hashable {
    case homeView
    case searchView
    case detailView(activityID: String)
    
}

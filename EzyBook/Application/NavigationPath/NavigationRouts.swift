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
    case reviewView(activityID: String)
    case chatRoomView(roomID: String, opponentID: String)
    
}

extension HomeRoute {
    var hidesTabbar: Bool {
        switch self {
        case .detailView, .reviewView, .chatRoomView:
            return true
        default:
            return false
        }
    }
}


enum CommunityRoute: Hashable {
    case communityView
}

enum ProfileRoute: Hashable {
    case profileView
    case orderListView(list: [OrderEntity])
    
}

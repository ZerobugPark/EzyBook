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
    case chatRoomView(roomID: String, opponentNick: String)
    case advertiseView(callbackID: UUID)
    
}

extension HomeRoute {
    var hidesTabbar: Bool {
        switch self {
        case .detailView, .reviewView, .chatRoomView, .advertiseView, .searchView:
            return true
        default:
            return false
        }
    }
}


enum CommunityRoute: Hashable {
    case communityView
    case postView
    case detailView(postID: String)
}
extension CommunityRoute {
    
    var hidesTabbar: Bool {
        switch self {
        case .postView, .detailView:
            return true
        default:
            return false
        }
    }
}



enum ChatRoute: Hashable {
    case chatView
    case chatRoomView(roomID: String, opponentNick: String)
}

extension ChatRoute {
    var hidesTabbar: Bool {
        switch self {
        case .chatRoomView:
            return true
        default:
            return false
        }
    }
}

enum ProfileRoute: Hashable {
    case profileView
    case orderListView(list: [OrderEntity])
    case reviewListView(list: [OrderEntity])
    
}

extension ProfileRoute {
    var hidesTabbar: Bool {
        switch self {
        case .orderListView, .reviewListView:
            return true
        default:
            return false
        }
    }
}

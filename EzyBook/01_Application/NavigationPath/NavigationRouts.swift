//
//  NavigationRouts.swift
//  EzyBook
//
//  Created by youngkyun park on 5/22/25.
//

import SwiftUI

enum AuthRoute {
    case emailLogin

}

enum HomeRoute: Hashable {
    case searchView
    case detailView(activityID: String)
    case reviewView(activityID: String)
    case chatRoomView(roomID: String, opponentNick: String)
    case advertiseView(callbackID: UUID)
    
}

enum CommunityRoute: Hashable {
    case communityView
    case postView(status: PostStatus)
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
    case chatRoomView(roomID: String, opponentNick: String)
}

enum ProfileRoute: Hashable {
    case profileView
    case orderListView(list: [OrderEntity])
    case reviewListView(list: [OrderEntity])
    case activityLikeList
    case myPost(postCategory: ProfilePostCategory)
    case modifyPost(mode: PostStatus, token: UUID)
    
}

extension ProfileRoute {
    var hidesTabbar: Bool {
        switch self {
        case .profileView:
            return false
        default:
            return true
        }
    }
}

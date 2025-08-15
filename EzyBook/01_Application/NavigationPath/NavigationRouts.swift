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
    case postView(status: PostStatus)
    case detailView(postID: String)
}


enum ChatRoute: Hashable {
    case chatRoomView(roomID: String, opponentNick: String)
}

enum ProfileRoute: Hashable {
    case orderListView(list: [OrderEntity])
    case reviewListView(list: [OrderEntity])
    case activityLikeList
    case myPost(postCategory: ProfilePostCategory)
    case modifyPost(mode: PostStatus, token: UUID)
    
}


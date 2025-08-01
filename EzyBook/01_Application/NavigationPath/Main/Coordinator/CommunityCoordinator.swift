//
//  CommunityCoordinator.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

final class CommunityCoordinator: ObservableObject {
    
    
    @Published var path = NavigationPath()
    @Published var isTabbarHidden: Bool = false
    
    private let container: CommunityDIContainer
    
    init(container: CommunityDIContainer) {
        self.container = container

    }
    
    func push(_ route: CommunityRoute) {
        path.append(route)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
    
    
    @ViewBuilder
    func destinationView(route: CommunityRoute) -> some View {
        switch route {
        case .communityView:
            CommunityView()
            //CommunityView(coordinator: self)
        }
    }

}


extension CommunityCoordinator {
 
    func makePostsView() -> some View {
        return PostsView()
    }
}

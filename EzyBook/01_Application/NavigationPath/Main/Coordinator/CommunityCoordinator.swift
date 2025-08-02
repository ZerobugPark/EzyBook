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
    
    private var tabbarHiddenStack: [Bool] = []
    
    private let container: CommunityDIContainer
    
    init(container: CommunityDIContainer) {
        self.container = container

    }
    
    func push(_ route: CommunityRoute) {
        let shouldHide = route.hidesTabbar
        tabbarHiddenStack.append(shouldHide)
        isTabbarHidden = shouldHide
        path.append(route)
    }

    func pop() {
        path.removeLast()
        _ = tabbarHiddenStack.popLast()
        isTabbarHidden = tabbarHiddenStack.last ?? false
    }

    func popToRoot() {
        path = NavigationPath()
        tabbarHiddenStack = []
        isTabbarHidden = false
    }
    
    
    @ViewBuilder
    func destinationView(route: CommunityRoute) -> some View {
        switch route {
        case .communityView:
            let vm = container.makeCommunityViewModel()
            CommunityView(viewModel: vm, coordinator: self)
        case .postView:
            PostsView(coordinator: self)
        }
    }

}


extension CommunityCoordinator {
 
    func makeMyActivityView(onConfirm: @escaping (OrderList) -> Void) -> some View {
        let vm = container.makeMyActivityListViewModel()
        return MyActivityListView(viewModel: vm, onConfirm: onConfirm)
    }
}

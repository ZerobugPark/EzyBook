//
//  MainModelObject.swift
//  EzyBook
//
//  Created by youngkyun park on 5/22/25.
//

import SwiftUI

final class HomeCoordinator: ObservableObject {
    
    
    @Published var path = NavigationPath()
    
    private let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container

    }
    
    func push(_ route: HomeRoute) {
        path.append(route)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
    
    
    @ViewBuilder
    func destinationView(route: HomeRoute) -> some View {
        switch route {
        case .homeView:
            HomeView(viewModel: self.container.makeHomeViewModel(), coordinator: self)
        case .searchView:
            SearchView(viewModel: self.container.makeSearchViewModel(), coordinator: self)
        case .detailView(let id):
            DetailView(viewModel: self.container.makeDetailViewModel(), coordinator: self, activityID: id)
        }
    }

}

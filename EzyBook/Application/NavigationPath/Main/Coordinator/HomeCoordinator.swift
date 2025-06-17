//
//  HomeCoordinator.swift
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
        case .reviewView(let id):
            ReviewView(activityID: id)
        }
    }

}


extension HomeCoordinator {
    func makeVideoPlayerView(path: String) -> some View {
        let viewModel = container.makeVideoPlayerViewModel()
        return VideoPlayerView(path: path, viewModel: viewModel)
    }
    
    func makeImageViewer(path: String) -> some View {
        let viewModel = container.makeZoomableImageFullScreenViewModel()
        return ZoomableImageFullScreenView(path: path, viewModel: viewModel)

    }
    
    
    func makePaymentView(item: PayItem, onFinish: @escaping () -> Void) -> some View {
        return PaymentView(item: item, onFinish: onFinish)
    }
    

}

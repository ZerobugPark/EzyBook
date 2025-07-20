//
//  HomeCoordinator.swift
//  EzyBook
//
//  Created by youngkyun park on 5/22/25.
//

import SwiftUI

final class HomeCoordinator: ObservableObject {
    
    
    @Published var path = NavigationPath()
    
    @Published var isTabbarHidden: Bool = false
    private var tabbarHiddenStack: [Bool] = []

    private let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
        
    }
    
    func push(_ route: HomeRoute) {
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
    func destinationView(route: HomeRoute) -> some View {
        switch route {
        case .homeView:
            HomeView(viewModel: self.container.makeHomeViewModel(), coordinator: self)
        case .searchView:
            SearchView(
                viewModel: self.container.makeSearchViewModel(),
                bannerViewModel: self.container.makeBannerViewModel(), coordinator: self
            )
        case .detailView(let id):
            DetailView(viewModel: self.container.makeDetailViewModel(), coordinator: self, activityID: id)
        case .reviewView(let id):
            ReviewView(activityID: id)
        case .chatRoomView(let roomID, let opponentNick):
            ChatRoomView(viewModel: self.container.makeChatRoomViewModel(roomID: roomID, opponentNick: opponentNick)) { [weak self] in
                self?.pop()
            }
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
    
    
    func makePaymentView(item: PayItem, onFinish: @escaping (DisplayError?) -> Void) -> some View {
        let viewModel = container.makePaymentViewModel()
        return PaymentView(item: item, onFinish: onFinish, viewModel: viewModel)
    }
    
    
}

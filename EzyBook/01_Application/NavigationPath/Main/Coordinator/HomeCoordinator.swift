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
    
    /// 네비게이션 스택에서 콜백 함수를 받기 위한 딕셔너리 처리
    var callbacks: [UUID: (String) -> Void] = [:]

    private let container: AppDIContainer
    
    init(container: AppDIContainer) {
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
    
    //  광고(WebView) 전용 push
    func pushAdvertiseView(onComplete: @escaping (String) -> Void) {
        let id = UUID()
        callbacks[id] = onComplete
        push(.advertiseView(callbackID: id))
    }

    //  광고 완료 시 콜백 실행 후 pop
    func completeAdvertise(id: UUID, message: String) {
        callbacks[id]?(message)
        callbacks.removeValue(forKey: id)
        pop()
    }
    

    
    @ViewBuilder
    func destinationView(route: HomeRoute) -> some View {
        switch route {
        case .homeView:
            HomeView(viewModel: self.container.homeDIContainer.makeHomeViewModel(), coordinator: self)
        case .searchView:
            SearchView(
                viewModel: self.container.homeDIContainer.makeSearchViewModel(),
                bannerViewModel: self.container.homeDIContainer.makeBannerViewModel(), coordinator: self
            )
        case .detailView(let id):
            
            let vm = self.container.homeDIContainer.makeDetailViewModel(id: id)
            DetailView(viewModel: vm, coordinator: self)
        case .reviewView(let id):
            let vm = self.container.homeDIContainer.makeReviewViewModel(id: id)
            ReviewView(viewModel: vm, coordinator: self)
        case .chatRoomView(let roomID, let opponentNick):
            ChatRoomView(viewModel: self.container.chatDIContainer.makeChatRoomViewModel(roomID: roomID, opponentNick: opponentNick)) { [weak self] in
                self?.pop()
            }
        case .advertiseView(let callbackID):
            WebViewScreen(
                tokenManager: container.storage,
                coordinator: self) { [weak self] msg in
                    self?.completeAdvertise(id: callbackID, message: msg)
                    
                }
         
        }
    }
    
}





extension HomeCoordinator {
    func makeVideoPlayerView(path: String) -> some View {
        let viewModel = container.homeDIContainer.makeVideoPlayerViewModel()
        return VideoPlayerView(viewModel: viewModel, path: path)
    }
    
    func makeImageViewer(path: String) -> some View {
        let viewModel = container.homeDIContainer.makeZoomableImageFullScreenViewModel()
        return ZoomableImageFullScreenView(viewModel: viewModel, path: path)
        
    }
    
    
    func makePaymentView(item: PayItem, onFinish: @escaping (DisplayMessage?) -> Void) -> some View {
        let viewModel = container.homeDIContainer.makePaymentViewModel()
        return PaymentView(item: item, onFinish: onFinish, viewModel: viewModel)
    }
    
    
}

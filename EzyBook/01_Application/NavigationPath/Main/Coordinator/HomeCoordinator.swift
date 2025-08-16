//
//  HomeCoordinator.swift
//  EzyBook
//
//  Created by youngkyun park on 5/22/25.
//

import SwiftUI

@MainActor
final class HomeCoordinator: ObservableObject {
    
    /// 디테일뷰 재생성 방지
    @Published var routeStack: [HomeRoute] = []
    
    /// 네비게이션 스택에서 콜백 함수를 받기 위한 딕셔너리 처리
    var callbacks: [UUID: (String) -> Void] = [:]

    private let factory: HomeFactory
    
    private lazy var homeViewModel = factory.makeHomeViewModel()
    
    private var detailViewModel: DetailViewModel?
    private var searchViewModel: SearchViewModel?
    private var bannerViewModel: BannerViewModel?
    
    private func detailVM(for id: String) -> DetailViewModel {
        if let vm = detailViewModel { return vm }
        let vm = factory.makeDetailViewModel(id: id)
        detailViewModel = vm
        return vm
    }
    
    private func getSearchVM() -> SearchViewModel {
        if let vm = searchViewModel { return vm }
        let vm = factory.makeSearchViewModel()
        searchViewModel = vm
        return vm
    }

    private func getBannerVM() -> BannerViewModel {
        if let vm = bannerViewModel { return vm }
        let vm = factory.makeBannerViewModel()
        bannerViewModel = vm
        return vm
    }
    
    init(factory: HomeFactory) {
        self.factory = factory
    }
    
}

// MARK: Stack
extension HomeCoordinator {
    @ViewBuilder
    func rootView() -> some View {
        HomeView(coordinator: self, viewModel: self.homeViewModel)
    }
    
    
    func push(_ route: HomeRoute) {
        routeStack.append(route)
        
    }
    
    func pop() {
            
        guard let last = routeStack.popLast() else { return }
        
        switch last {
        case .detailView:
            detailViewModel = nil
        case .searchView:
            searchViewModel = nil
            bannerViewModel = nil
        default: break
        }
        
    }
    
    func popToRoot() {
        routeStack.removeAll()
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
        case .searchView:
              SearchView(
                viewModel: getSearchVM(),
                  bannerViewModel: getBannerVM(),
                  coordinator: self
              )
            
        case .detailView(let id):
            DetailView(viewModel: detailVM(for: id), coordinator: self)
            
        case .reviewView(let id):
            let vm = factory.makeReviewViewModel(id: id)
            ReviewView(viewModel: vm, coordinator: self)
        case .chatRoomView(let roomID, let opponentNick):
            let vm = factory.makeChatRoomViewModel(roomID: roomID, opponentNick: opponentNick)
            ChatRoomView(viewModel: vm) { [weak self] in
                self?.pop()
            }
        case .advertiseView(let callbackID):
            WebViewScreen(
                tokenManager: KeyChainTokenStorage.shared,
                coordinator: self) { [weak self] msg in
                    self?.completeAdvertise(id: callbackID, message: msg)

                }
         
        }
    }
}


// MARK: FullScreen
extension HomeCoordinator {
    func makeVideoPlayerView(path: String) -> some View {
        let viewModel = factory.makeVideoPlayerViewModel()
        return VideoPlayerView(viewModel: viewModel, path: path)
    }
    
    func makeImageViewer(path: String) -> some View {
        let viewModel = factory.makeZoomableImageFullScreenViewModel()
        return ZoomableImageFullScreenView(viewModel: viewModel, path: path)
        
    }
    
    
    func makePaymentView(item: PayItem, onFailed: ((DisplayMessage) -> Void)?, onSuccess: ((String, String) -> Void)?) -> some View {
        
        return PaymentView(item: item, onFailed: onFailed, onSuccess: onSuccess)
    }
    

}

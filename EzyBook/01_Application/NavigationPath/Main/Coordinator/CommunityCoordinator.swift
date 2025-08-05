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
    
    private let container: AppDIContainer
    
    
    init(container: AppDIContainer) {
        self.container = container

    }
    
    func push(_ route: CommunityRoute) {
        let shouldHide = route.hidesTabbar
        tabbarHiddenStack.append(shouldHide)
        isTabbarHidden = shouldHide
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.path.append(route)
        }
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
            let vm = container.communityDIContainer.makeCommunityViewModel()
            CommunityView(viewModel: vm, coordinator: self)
        case .postView:
            let vm =  container.communityDIContainer.makePostViewModel()
            PostsView(coordinator: self, viewModel: vm)
        case .detailView(let id):
            let vm =  container.communityDIContainer.makePostDetailViewModel(postID: id)
            PostDetailView(viewModel: vm, coordinator: self)
        }
    }

}


extension CommunityCoordinator {
 
    func makeMyActivityView(onConfirm: @escaping (OrderList) -> Void) -> some View {
        let vm =  container.communityDIContainer.makeMyActivityListViewModel()
        return MyActivityListView(viewModel: vm, onConfirm: onConfirm)
    }
    
    func makeVideoPlayerView(path: String) -> some View {
        let viewModel = container.homeDIContainer.makeVideoPlayerViewModel()
        return VideoPlayerView(viewModel: viewModel, path: path)
    }
    
    func makeImageViewer(path: String) -> some View {
        let viewModel = container.homeDIContainer.makeZoomableImageFullScreenViewModel()
        return ZoomableImageFullScreenView(viewModel: viewModel, path: path)
        
    }
    
    func makeReplyView(data: CommentEntity, postID: String, onChange: @escaping ()-> Void) -> some View {
        let vm = container.communityDIContainer.makeReplyViewModle(data: data, postID: postID)
        
        return ReplyView(coordinator: self, viewModel: vm,onChagned: onChange)
    }

    func makeModifyView(data: ModifyComment, onSave: @escaping (String)-> Void) -> some View {
        
        return CommnetModifyView(initialText: data.text, onSave: onSave)
        
    }

    
    
}

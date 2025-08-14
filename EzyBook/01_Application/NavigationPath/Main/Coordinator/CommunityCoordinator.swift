//
//  CommunityCoordinator.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

final class CommunityCoordinator: ObservableObject, PostsRouting {

    @Published var routeStacks: [CommunityRoute] = []
    private let factory: CommunityFactory
    
    private lazy var communityViewModel = factory.makeCommunityViewModel()
    
    private lazy var postsRouter: AnyPostsRouter = {
        AnyPostsRouter(CommunityCoordinatorRouter(coordinator: self))
    }()
    
    private var postViewModel: PostViewModel?
    
    private func postVM(for status: PostStatus) -> PostViewModel {
        if let vm = postViewModel { return vm }
        let vm = factory.makePostViewModel(status)
        postViewModel = vm
        return vm
    }
    
    init(factory: CommunityFactory) {
        self.factory = factory

    }
    

    
}

extension CommunityCoordinator {
 
    @ViewBuilder
    func rootView() -> some View {
        CommunityView(viewModel: communityViewModel, coordinator: self)
    }
    
    func push(_ route: CommunityRoute) {
        self.routeStacks.append(route)
    }

    func pop() {
        
        guard let last = routeStacks.popLast() else { return }
        
        switch last {
        case .postView:
            postViewModel = nil
        default: break
        
        }
        
        _ = routeStacks.popLast()
        
    }

    func popToRoot() {
        routeStacks.removeAll()
        
    }
    
    
    @ViewBuilder
    func destinationView(route: CommunityRoute) -> some View {
        switch route {
        case .postView(let status):
            PostsView(router: postsRouter, viewModel: postVM(for: status))
        case .detailView(let id):
            let vm =  factory.makePostDetailViewModel(postID: id)
            PostDetailView(coordinator: self, viewModel: vm)
        }
    }
    
 
    
}


extension CommunityCoordinator {
 
    func makeMyActivityView(onConfirm: @escaping (OrderList) -> Void) -> some View {
        let vm =  factory.makeMyActivityListViewModel()
        return MyActivityListView(viewModel: vm, onConfirm: onConfirm)
    }
    
    func makeVideoPlayerView(path: String) -> some View {
        let viewModel = factory.makeVideoPlayerViewModel()
        return VideoPlayerView(viewModel: viewModel, path: path)
    }
    
    func makeImageViewer(path: String) -> some View {
        let viewModel = factory.makeZoomableImageFullScreenViewModel()
        return ZoomableImageFullScreenView(viewModel: viewModel, path: path)
        
    }
    
    func makeReplyView(data: CommentEntity, postID: String, onChange: @escaping ()-> Void) -> some View {
        let vm = factory.makeReplyViewModle(data: data, postID: postID)
        return ReplyView(coordinator: self, viewModel: vm,onChagned: onChange)
    }

    func makeModifyView(data: ModifyComment, onSave: @escaping (String)-> Void) -> some View {
        return CommnetModifyView(initialText: data.text, onSave: onSave)

    }

    
    
}

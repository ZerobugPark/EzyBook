//
//  ProfileCoordinator.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

final class ProfileCoordinator: ObservableObject, PostsRouting {
    
    
    @Published var routeStack: [ProfileRoute] = []

    
    private var modifyCallbacks: [UUID: (ModifyPost?) -> Void] = [:]
    
    
    private lazy var profileViewModel = factory.makeProfileViewModel()
    private lazy var profileSupplementaryViewModel = factory.makeProfileSupplementaryViewModel()
    
    private lazy var postsRouter: AnyPostsRouter = {
        AnyPostsRouter(ProfileCoordinatorRouter(coordinator: self))
    }()
    
    private var postViewModel: PostViewModel?
    private var myPostViewModel: MyPostViewModel?
    
    private let factory: ProfileFactory
    
    
    private func postVM(for mode: PostStatus) -> PostViewModel {
        if let vm = postViewModel { return vm }
        let vm = factory.makePostViewModel(mode: mode)
        postViewModel = vm
        return vm
    }
    
    private func myPostVM(for category: ProfilePostCategory) -> MyPostViewModel {
        if let vm = myPostViewModel { return vm }
        let vm = factory.makeMyPostViewModel(postCategory: category)
        myPostViewModel = vm
        return vm
    }
    
    

    init(factory: ProfileFactory) {
        self.factory = factory

    }
    


}

extension ProfileCoordinator {
    
    @ViewBuilder
    func rootView() -> some View {
        ProfileView(viewModel: profileViewModel, supplementViewModel: profileSupplementaryViewModel, coordinator: self)
    }
    
    func push(_ route: ProfileRoute) {

        routeStack.append(route)
    }


    func pop() {
        guard let last = routeStack.popLast() else { return }

        switch last {
        case .myPost:
            myPostViewModel = nil
        case let .modifyPost(_, token):
            postViewModel = nil
            modifyCallbacks.removeValue(forKey: token)
        default: break
        }
        
    }

    func popToRoot() {
        routeStack.removeAll()
    }
    
    
    @ViewBuilder
    func destinationView(route: ProfileRoute) -> some View {
        switch route {
        case .orderListView(let list):
            let vm = factory.makeOrderListViewModel(orderList: list)
            OrderListView(coordinator: self, viewModel: vm)
        case .reviewListView(let list):
            let vm = factory.makeReviewViewModel(list: list)
            ReviewDetailView(coordinator: self, viewModel: vm) { data in
                    vm.action(.modifyReview(data: data))
                }
        case .activityLikeList:
            let vm = factory.makeActiviyLikeViewModel()
            ActivityLikeView(coordinator: self, viewModel: vm)
        case .myPost(let postCategory):
            MyPostView(coordinator: self, viewModel: myPostVM(for: postCategory))
        case .modifyPost(let mode, let token):
            PostsView(router: postsRouter, viewModel: postVM(for: mode), isModified: { [weak self] modified in
                    self?.completeModify(token: token, result: modified)
                }
            )
        }
    }

    func completeModify(token: UUID, result: ModifyPost?) {
        /// 딕셔너리에 지우면서 삭제된 값 만환
        modifyCallbacks.removeValue(forKey: token)?(result)
    }
    
    func pushModify(mode: PostStatus, onCompleted: @escaping (ModifyPost?) -> Void) {
        let token = UUID()
        modifyCallbacks[token] = onCompleted
        push(.modifyPost(mode: mode, token: token))
    }
     
}

extension ProfileCoordinator {
    func makeConfirmImageView(image: UIImage, onConfirm: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) -> some View {
            ConfirmImageView(image: image, onConfirm: onConfirm, onCancel: onCancel)
    }
    
    func makeWriteReviewView(_ activityID: String, _ orderCode: String) -> some View {
        let vm = factory.makeWriteReviewViewModel(id: activityID, code: orderCode)
        return ReviewWriteView(viewModel: vm) {
            self.popToRoot()
        }
    }
    
    func makeProfileModifyView(onConfirm: @escaping (ProfileLookUpEntity?) -> Void) -> some View {
        let vm = factory.makeProfileModifyViewModel()
        return ProfileModifyView(viewModel: vm, onConfirm: onConfirm)
    }
    
    func makeModifyReviewView(_ data: UserReviewDetailList, onConfirm: @escaping (UserReviewDetailList?) -> Void) -> some View {
        let vm = factory.makeModifyReviewViewModel(data)
        return ReviewModifyView(viewModel: vm, onConfirm: onConfirm)
    }
    
    
}
 

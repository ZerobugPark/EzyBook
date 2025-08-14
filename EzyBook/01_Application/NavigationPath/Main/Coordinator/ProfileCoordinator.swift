//
//  ProfileCoordinator.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

final class ProfileCoordinator: ObservableObject, PostsRouting {
    
    
    @Published var path = NavigationPath()
    @Published var isTabbarHidden: Bool = false
    private var tabbarHiddenStack: [Bool] = []
    
    private var modifyCallbacks: [UUID: (ModifyPost?) -> Void] = [:]
    
    private let container: AppDIContainer
    
    private lazy var profileVM = container.profileDIContainer.makeFactory().makeProfileVM()
    
    

    init(container: AppDIContainer) {
        self.container = container

    }
    
    func push(_ route: ProfileRoute) {
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
    func destinationView(route: ProfileRoute) -> some View {
        switch route {
        case .profileView:
            let vm = self.container.profileDIContainer.makeProfileViewModel()
            let sVm = self.container.profileDIContainer.makeProfileSupplementaryViewModel()
            ProfileView(
                viewModel: vm,
                supplementViewModel: sVm,
                coordinator: self
            )
        case .orderListView(let list):
            let vm = self.container.profileDIContainer.makeOrderListViewModel(orderList: list)
            OrderListView(viewModel: vm, coordinator: self)
        
        case .reviewListView(let list):
            let vm = self.container.profileDIContainer.makeReviewViewModel(list: list)
            ReviewDetailView(
                viewModel: vm,
                coordinator: self) { data in
                    vm.action(.modifyReview(data: data))
                }
            
        case .activityLikeList:
            let vm = self.container.profileDIContainer.makeActiviyLikeViewModel()
            ActivityLikeView(viewModel: vm, coordinator: self)
        case .myPost(let postCategory):
            let vm = self.container.profileDIContainer.makeMyPostViewModel(postCategory: postCategory)
            MyPostView(viewModel: vm, coordinator: self)
        case .modifyPost(let mode, let token):
            EmptyView()
//            let vm = self.container.communityDIContainer.makePostViewModel(mode)
//            let router = AnyPostsRouter(ProfileCoordinatorRouter(coordinator: self))
//            PostsView(
//                router: router,
//                isModified: { [weak self] modified in
//                    self?.completeModify(token: token, result: modified)
//                }, viewModel: vm
//            )
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
        let vm = self.container.profileDIContainer.makeWriteReviewViewModel(id: activityID, code: orderCode)
        return ReviewWriteView(viewModel: vm) {
            self.popToRoot()
        }
    }
    
    func makeProfileModifyView(onConfirm: @escaping (ProfileLookUpEntity?) -> Void) -> some View {
        let vm = self.container.profileDIContainer.makeProfileModifyViewModel()
        return ProfileModifyView(viewModel: vm, onConfirm: onConfirm)
    }
    
    func makeModifyReviewView(_ data: UserReviewDetailList, onConfirm: @escaping (UserReviewDetailList?) -> Void) -> some View {
        let vm = self.container.profileDIContainer.makeModifyReviewViewModel(data)
        return ReviewModifyView(viewModel: vm, onConfirm: onConfirm)
    }
    
    
}
 

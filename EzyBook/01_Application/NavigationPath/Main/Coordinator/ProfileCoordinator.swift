//
//  ProfileCoordinator.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

final class ProfileCoordinator: ObservableObject {
    
    
    @Published var path = NavigationPath()
    @Published var isTabbarHidden: Bool = false
    private var tabbarHiddenStack: [Bool] = []
    
    
    private let container: ProfileDIContainer
    
    init(container: ProfileDIContainer) {
        self.container = container

    }
    
    func push(_ route: ProfileRoute) {
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
    func destinationView(route: ProfileRoute) -> some View {
        switch route {
        case .profileView:
            let vm = self.container.makeProfileViewModel()
            let sVm = self.container.makeProfileSupplementaryViewModel()
            ProfileView(
                viewModel: vm,
                supplementviewModel: sVm,
                coordinator: self
            )
        case .orderListView(let list):
            let vm = self.container.makeOrderListViewModel(orderList: list)
            OrderListView(
                viewModel: vm,
                coordinator: self) { orderCode, rating in
                    vm.action(.updateRating(orderCode: orderCode, rating: rating))
                }
        case .reviewListView(let list):
            let vm = self.container.makeReviewViewModel(list: list)
            ReviewDetailView(viewModel: vm, coordinator: self)
        }
    }

}

extension ProfileCoordinator {
    func makeConfirmImageView(image: UIImage, onConfirm: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) -> some View {
            ConfirmImageView(image: image, onConfirm: onConfirm, onCancel: onCancel)
    }
    
    func makeWriteReviewView(_ activityID: String, _ orderCode: String, onConfirm: @escaping (String, Int) -> Void) -> some View {
        let vm = self.container.makeWriteReviewViewModel(id: activityID, code: orderCode)
        return WriteReViewView(onConfirm: onConfirm, viewModel: vm)
    }
    
    func makeProfileModifyView(onConfirm: @escaping (ProfileLookUpEntity?) -> Void) -> some View {
        let vm = self.container.makeProfileModifyViewModel()
        return ProfileModifyView(viewModel: vm, onConfirm: onConfirm)
    }
    
}
 

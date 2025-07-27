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
    
    private let container: ProfileDIContainer
    
    init(container: ProfileDIContainer) {
        self.container = container

    }
    
    func push(_ route: ProfileRoute) {
        path.append(route)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
    
    
    @ViewBuilder
    func destinationView(route: ProfileRoute) -> some View {
        switch route {
        case .profileView:
            ProfileView(
                viewModel: self.container.makeProfileViewModel(),
                supplementviewModel: self.container.makeProfileSupplementaryViewModel(),
                coordinator: self
            )
        case .orderListView(let list):
            OrderListView(orderList: list, viewModel: self.container.makeOrderListViewModel(), coordinator: self)
        }
    }

}

extension ProfileCoordinator {
    func makeConfirmImageView(image: UIImage, onConfirm: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) -> some View {
            ConfirmImageView(image: image, onConfirm: onConfirm, onCancel: onCancel)
    }
    
    func makeWriteReviewView(_ activityID: String, _ orderCode: String, onConfirm: @escaping (String, Int) -> Void) -> some View {
        WriteReViewView(activityId: activityID, orderCode: orderCode, onConfirm: onConfirm, viewModel: self.container.makeWriteReviewViewModel())
    }
    
}
 

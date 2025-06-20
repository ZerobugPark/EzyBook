//
//  ProfileCoordinator.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI

final class ProfileCoordinator: ObservableObject {
    
    
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
    func destinationView(route: ProfileRoute) -> some View {
        switch route {
        case .profileView:
            ProfileView(viewModel: self.container.makeProfileViewModel(), coordinator: self)
        }
    }

}

extension ProfileCoordinator {
    func makeConfirmImageView(image: UIImage, onConfirm: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) -> some View {
            ConfirmImageView(image: image, onConfirm: onConfirm, onCancel: onCancel)
    }
    
}

//
//  ChatCoordinator.swift
//  EzyBook
//
//  Created by youngkyun park on 7/10/25.
//

import SwiftUI

final class ChatCoordinator: ObservableObject {
    
    
    @Published var path = NavigationPath()
    @Published var isTabbarHidden: Bool = false
    
    private var tabbarHiddenStack: [Bool] = []
    
    private let container: ChatDIContainer
    
    init(container: ChatDIContainer) {
        self.container = container
        
    }
    
    func push(_ route: ChatRoute) {
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
    func destinationView(route: ChatRoute) -> some View {
        switch route {
        case .chatView:
            ChatListView(viewModel: self.container.makeChatListViewModel(), coordinator: self)
        case .chatRoomView(let roomID, let opponentNick):
            ChatRoomView(viewModel: self.container.makeChatRoomViewModel(roomID: roomID, opponentNick: opponentNick)) { [weak self] in
                self?.pop()
            }
        }
        
    }
}
    

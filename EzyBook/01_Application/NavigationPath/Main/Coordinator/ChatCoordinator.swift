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
    
    private let factory: ChatFactory
    
    private lazy var chatListViewModel = factory.makeChatListViewModel()
    
    init(factory: ChatFactory) {
        self.factory = factory
        
    }
    

}

extension ChatCoordinator {
    
    
    @ViewBuilder
    func rootView() -> some View {
        ChatListView(viewModel: self.chatListViewModel, coordinator: self)
    }
    
    
    func push(_ route: ChatRoute) {
        self.path.append(route)
    }
    
    func pop() {
        path.removeLast()
        _ = tabbarHiddenStack.popLast()
        isTabbarHidden = tabbarHiddenStack.last ?? false
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
    
    
    @ViewBuilder
    func destinationView(route: ChatRoute) -> some View {
        switch route {
        case .chatRoomView(let roomID, let opponentNick):
            let vm = factory.makeChatRoomViewModel(roomID: roomID, opponentNick: opponentNick)
            ChatRoomView(viewModel: vm) { [weak self] in
                self?.pop()
            }
        }
        
    }
    
    
}

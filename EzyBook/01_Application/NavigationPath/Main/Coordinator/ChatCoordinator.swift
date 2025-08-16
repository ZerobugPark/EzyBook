//
//  ChatCoordinator.swift
//  EzyBook
//
//  Created by youngkyun park on 7/10/25.
//

import SwiftUI

final class ChatCoordinator: ObservableObject {
    
    @Published var routeStack: [ChatRoute] = []
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
        routeStack.append(route)
    }
    
    func pop() {
        _ = routeStack.popLast()

    }
    
    func popToRoot() {
        routeStack.removeAll()
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

//
//  ChatRoomViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import SwiftUI
import Combine

final class ChatRoomViewModel: ViewModelType {
    
    private let socketService: SocketService
    private let roomID: String
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    private var scale: CGFloat = 0
      
    init(
        socketService: SocketService,
        roomID: String
    ) {

        self.socketService = socketService
        self.roomID = roomID
       
        transform()
    }
    
    
    deinit {
        socketService.disconnect()
    }
}

// MARK: Input/Output
extension ChatRoomViewModel {
    
    struct Input {  }
    
    struct Output {
        var presentedError: DisplayError? = nil
    }
    
    func transform() {}
    
    
    private func handleConnectSocket() {
        socketService.connect()
    }
    
    
}

// MARK: Action
extension ChatRoomViewModel {
    
    enum Action {
        case startChat
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .startChat:
            handleConnectSocket()
        }
    }
    
    
}


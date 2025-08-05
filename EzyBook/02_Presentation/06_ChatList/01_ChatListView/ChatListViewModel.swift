//
//  ChatListViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 7/10/25.
//

import SwiftUI
import Combine

final class ChatListViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    private let fetchChatListUseCase: FetchRealmChatRoomListUseCase
    private let chatListUseCase: ChatRemoteRoomListUseCase
    
    
    private var userID: String {
        UserSession.shared.currentUser!.userID
    }
    
    
    init(
        fetchChatListUseCase: FetchRealmChatRoomListUseCase,
        chatListUseCase: ChatRemoteRoomListUseCase,
    ) {
        
        self.fetchChatListUseCase = fetchChatListUseCase
        self.chatListUseCase = chatListUseCase
        
        requestChatRoomList()
        transform()
    }
    
    
    deinit {
        
    }
}

// MARK: Input/Output
extension ChatListViewModel {
    
    struct Input {  }
    
    struct Output {
        
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        
        var chatRoomList: [LastMessageSummary] = []
        
        
    }
    
    func transform() {}
    
    
    
    @MainActor
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            output.presentedMessage = DisplayMessage.error(code: apiError.code, msg: apiError.userMessage)
        } else {
            output.presentedMessage = DisplayMessage.error(code: -1, msg: error.localizedDescription)
        }
    }
    
    
    
    private func requestChatRoomList() {
        
        loadChatRoomsFromRealm()
        Task { await loadChatRoomsFromServer() }
        
    }
    
}


// MARK: 채팅 목록 불러오기

extension ChatListViewModel {
    
    /// UI Update
    /// Realm에서 먼저 불러오기 (빠르게 UI 표시)
    private func loadChatRoomsFromRealm() {
        let realmData = fetchChatListUseCase.execute()
        if !realmData.isEmpty {
            output.chatRoomList = realmData
        }
    }
    
    
    /// 서버 호출
    private func loadChatRoomsFromServer() async {
        do {
            let remoteData = try await chatListUseCase.execute()
            
            dump(remoteData)
            await MainActor.run {
                output.chatRoomList = remoteData.filter{ $0.lastChat != nil }.map { $0.toLastMessageSummary(myID: userID) }
            }
        } catch {
            await handleError(error)
        }
        
        
    }
    
    
    
}



// MARK: Alert 처리
extension ChatListViewModel: AnyObjectWithCommonUI {
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
}

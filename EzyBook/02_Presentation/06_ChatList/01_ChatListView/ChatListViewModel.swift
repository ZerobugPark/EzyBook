//
//  ChatListViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 7/10/25.
//

import SwiftUI
import Combine
import RealmSwift

final class ChatListViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    private let fetchChatListUseCase: FetchRealmChatRoomListUseCase
    private let chatListUseCase: ChatRemoteRoomListUseCase
    private let unReadCountUseCase: GetUnReadChatCount
    
    private let realm: Realm = try! Realm()
    
    private var userID: String {
        UserSession.shared.currentUser!.userID
    }
    
    
    init(
        fetchChatListUseCase: FetchRealmChatRoomListUseCase,
        chatListUseCase: ChatRemoteRoomListUseCase,
        unReadCountUseCase: GetUnReadChatCount
    ) {
        
        self.fetchChatListUseCase = fetchChatListUseCase
        self.chatListUseCase = chatListUseCase
        self.unReadCountUseCase = unReadCountUseCase
        
        requestChatRoomList()
        transform()
        
        print(#function, Self.desc)
    }
    
    
    deinit {
        print(#function, Self.desc)
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
    
    func transform() {
        
        fetchChatListUseCase.publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] list in
                self?.applyRoomDiff(list)
            }
            .store(in: &cancellables)
     
        NotificationCenter.default.publisher(for: .updateMessageList)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.requestChatRoomList()
            }
            .store(in: &cancellables)
        
    }
    
    
    
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
            
            await MainActor.run {
                output.chatRoomList = remoteData
                    .filter{ $0.lastChat != nil }
                    .map { $0.toLastMessageSummary(myID: userID, unReadCount: unReadCountUseCase) }
            }
        } catch {
            await handleError(error)
        }
        
        
    }
    
    private func applyRoomDiff(_ newList: [LastMessageSummary]) {
        // 1) 업데이트/삽입
        for item in newList {
            if let idx = output.chatRoomList.firstIndex(where: { $0.roomID == item.roomID }) {
                // 변경이 있을 때만 대입 (불필요한 리렌더 방지)
                if output.chatRoomList[idx] != item {
                    output.chatRoomList[idx] = item
                }
            }
        }


        // 3) 최신순 정렬 유지
        output.chatRoomList.sort { $0.updateAt > $1.updateAt }
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

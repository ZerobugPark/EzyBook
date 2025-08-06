//
//  ChatRoomViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import SwiftUI
import Combine

final class ChatRoomViewModel: ViewModelType {
    
    private var socketService: SocketService
    private let roomID: String
    private let chatUseCases: ChatListUseCases
    
    private(set) var opponentNick: String
    private var chatMessageEntity: [ChatMessageEntity] = []
    
    var input = Input()
    
    @Published var output = Output()
    @Published var content = ""
    @Published var selectedImages: [UIImage] = []
    
    var cancellables = Set<AnyCancellable>()
    
    private var userID: String {
        UserSession.shared.currentUser!.userID
    }
    
    init(
        socketService: SocketService,
        roomID: String,
        chatUseCases: ChatListUseCases,
        opponentNick: String
    ) {
        
        self.socketService = socketService
        self.roomID = roomID
        self.chatUseCases = chatUseCases
        self.opponentNick = opponentNick
        
        loadInitialChatList()
        transform()
    }
    
    
    deinit {
        socketService.disconnect()
    }
}

// MARK: Input/Output
extension ChatRoomViewModel {
    
    struct Input {
        var sendButtonTapped = PassthroughSubject<String, Never>()
    }
    
    struct Output {
        
        var isLoading: Bool = false
        
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        
        
        var groupedChatList: [(date: Date, messages: [ChatMessageEntity])] = []
    }
    
    
    func transform() {
        
        input.sendButtonTapped.sink { [weak self] content  in
            
            guard let self else { return }
            
            performSendMessage(content: content, files: selectedImages)
            self.content = ""
            
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
    
    
    
}

// MARK: 채팅 셋업
extension ChatRoomViewModel {
    ///[채팅방 진입 시]
    ///1. 로컬 DB  채팅 내역 조회
    ///3. 서버에서 최신 채팅 내역 요청
    ///4. 데이터 저장 및 UI 업데이트
    ///5. 소켓 연결
    ///-> 데이터 동기화로 인하여 WebSocket연결이 지연 될 수 있기 때문에, 소켓 연결 후 최신 채팅 내역 한번 더 요청
    
    private func loadInitialChatList() {
        Task {
            await handleEnterChatRoom()
        }
    }
    
    
    // MARK: - Entry Point
    private func handleEnterChatRoom() async {
        
        
        // 1) Realm 데이터 즉시 로드 (초기 UI)
        await loadInitialChatData()
        
        
        // 2) 서버 최신 여부 동기화 (백그라운드)
        await syncChatListIfNeeded()
        
        // 3) 소켓 설정 및 연결
        configureSocket()
        socketService.connect()
    }
    
    
    // MARK: - Initial Load (Realm → UI 즉시 표시)
    private func loadInitialChatData() async {
        await MainActor.run {
            let messages = chatUseCases.fetchRealmMessageList.excute(
                roomID: roomID,
                before: nil,
                limit: 30,
                myID: userID
            )
            chatMessageEntity = messages
            // Initialize groupedChatList from scratch
            let calendar = Calendar.current
            let grouped = Dictionary(grouping: messages) {
                calendar.startOfDay(for: $0.createdAt)
            }
            output.groupedChatList = grouped
                .sorted { $0.key < $1.key }
                .map { ($0.key, $0.value) }
            
        }
    }
    
    
    // MARK: - Sync Logic (서버와 최신 여부 비교 후 새 메시지 동기화)
    private func syncChatListIfNeeded() async {
        guard let lastLocalMessage = await loadLocalLastMessage() else {
            // Realm도 비어있으면 전체 조회
            await requestChatList()
            return
        }
        
        do {
            let serverLatest = try await fetchChatListFromServer(lastLocalMessage.createdAt.toISOString())
            guard !serverLatest.isEmpty else { return }
            
            await saveAndLoadChatList(serverLatest)
        } catch {
            print("syncChatListIfNeeded error: \(error)")
        }
    }
    
    // MARK: - Socket Configuration
    private func configureSocket() {
        socketService.onConnect = { [weak self] in
            guard let self else { return }
            Task {
                await self.syncChatListIfNeeded()
            }
        }
        
        socketService.onMessageReceived = { [weak self] message in
            guard let self else { return }
            Task {
                await self.handleIncomingMessage(message)
            }
        }
    }
    
    
    
    
    // MARK: - Handle Incoming Message (실시간 소켓 메시지 append)
    private func handleIncomingMessage(_ message: ChatEntity) async {
        await MainActor.run {
            // Realm 저장
            chatUseCases.saveRealmMessages.execute(message: message, myID: userID)
            
            // UI append (중복 방지)
            if !chatMessageEntity.contains(where: { $0.chatID == message.chatID }) {
                let model = message.toEntity(myID: userID)
                chatMessageEntity.append(model)
                // Update groupedChatList
                appendToGroupedChatList(model)
            }
        }
    }
    
    
    // MARK: - Local Realm Helpers
    /// 최근 메시지 1개 (서버 동기화 기준)
    private func loadLocalLastMessage() async -> ChatMessageEntity? {
        await MainActor.run {
            return chatUseCases.fetchRealmLatestMessage.execute(roodID: roomID, myID: userID)
        }
    }
    
    // MARK: - Chat List Request (서버 → Realm 저장 → append or 전체 교체)
    private func requestChatList(_ next: String? = nil) async {
        do {
            let chatList = try await fetchChatListFromServer(next)
            
            if next == nil {
                // 전체 로드 (초기 진입 or Realm 비었을 때)
                await MainActor.run {
                    chatUseCases.saveRealmMessages.execute(chatList: chatList, myID: userID)
                    
                    /// 데이터의 정확성을 위해 렘에서 데이터 조회 SOT
                    let messages =  chatUseCases.fetchRealmMessageList.excute(
                        roomID: roomID,
                        before: nil,
                        limit: 30,
                        myID: userID
                    )
                    chatMessageEntity = messages
                }
            } else {
                // 추가 로드 (append)
                await saveAndLoadChatList(chatList)
            }
        } catch {
            print("requestChatList error: \(error)")
        }
    }
    
    /// 네트워크 순수 호출
    private func fetchChatListFromServer(_ next: String? = nil) async throws -> [ChatEntity] {
        let data = try await chatUseCases.fetchRemoteMessage.execute(id: roomID, next: next)
        return data
    }
    
    /// Realm 저장 후 UI append
    private func saveAndLoadChatList(_ chatList: [ChatEntity]) async {
        guard !chatList.isEmpty else { return }
        
        await MainActor.run {
            chatUseCases.saveRealmMessages.execute(chatList: chatList, myID: userID)
            
            let newMessages = chatList.filter { newMsg in
                !chatMessageEntity.contains { $0.chatID == newMsg.chatID }
            }.map { $0.toEntity(myID: userID) }
            
            chatMessageEntity.append(contentsOf: newMessages)
            // Update groupedChatList for each new message
            newMessages.forEach { appendToGroupedChatList($0) }
        }
    }

    // MARK: - Grouped Chat List Helper
    private func appendToGroupedChatList(_ message: ChatMessageEntity) {
        let date = Calendar.current.startOfDay(for: message.createdAt)
        if let index = output.groupedChatList.firstIndex(where: { $0.date == date }) {
            output.groupedChatList[index].messages.append(message)
        } else {
            output.groupedChatList.append((date: date, messages: [message]))
            output.groupedChatList.sort { $0.date < $1.date }
        }
    }
    
}





// MARK: 메시지 전송
extension ChatRoomViewModel {
    
    private func handleSendButtonTapped() {
        
        /// 양쪽 공백 제거
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else { return }
        input.sendButtonTapped.send(trimmed)
    }
    
    private func performSendMessage(content: String, files: [UIImage]) {
        Task {
            do {
                let fileUrls: [String]
                if files.isEmpty {
                    fileUrls = []
                } else {
                    fileUrls = await performUploadImage(roomID: roomID, files: files)
                }

                let data = try await chatUseCases.sendMessages.execute(roomId: roomID, content: content, files: fileUrls)

                await handleSendMessageSuccess(data)
            } catch {
                await handleError(error)
            }
        }
    }
    
    private func handleSendMessageSuccess(_ message: ChatEntity) async {
        await MainActor.run {
            // Realm 저장
            chatUseCases.saveRealmMessages.execute(message: message, myID: userID)
            
            let model = message.toEntity(myID: userID)
            selectedImages = []
            chatMessageEntity.append(model)
            appendToGroupedChatList(model)
        }
    }
    
    
    private func performUploadImage(roomID: String, files: [UIImage]) async -> [String] {
        
            do {
                let data = try await chatUseCases.uploadImage.execute(roodID: roomID, files: files)
                return data.files
                
            } catch {
                await handleError(error)
                return []
        }
    }
    
   
 
}



// MARK: Action
extension ChatRoomViewModel {
    
    enum Action {
        case sendButtonTapped
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .sendButtonTapped:
            handleSendButtonTapped()
        }
    }
    
    
}

// MARK: Alert 처리
extension ChatRoomViewModel: AnyObjectWithCommonUI {
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
}

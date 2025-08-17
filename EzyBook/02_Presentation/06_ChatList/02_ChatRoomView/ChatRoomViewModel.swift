//
//  ChatRoomViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/30/25.
//

import SwiftUI
import Combine

import PDFKit
import CoreGraphics


final class ChatRoomViewModel: ViewModelType {
    
    private var socketService: SocketService
    private(set) var roomID: String
    private let chatUseCases: ChatListUseCases
    
    private(set) var opponentNick: String
    private var chatMessageEntity: [ChatMessageEntity] = []
    // Socket sync gating & buffering
    private var isInitialSyncing: Bool = false
    private var bufferedSocketMessages: [ChatEntity] = []
    // Older-page loading gate
    private var isLoadingMore: Bool = false
    
    var input = Input()
    
    @Published var output = Output()
    @Published var content = ""
    @Published var selectedImages: [UIImage] = []
    @Published var selectedFileURL: URL?
    
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
        chatUseCases.resetUnReadCount.execute(roodID: self.roomID)
        
        print(#function, Self.desc)
    }
    
    
    deinit {
        socketService.disconnect()
        print(#function, Self.desc)
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
        var newMessage: Bool = false
    }
    
    
    func transform() {
        
        input.sendButtonTapped.sink { [weak self] content  in
            
            guard let self else { return }
            
            performSendMessage(content: content, imgase: selectedImages)
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
            await MainActor.run { output.isLoading = true }
            
            await handleEnterChatRoom()
            
            await MainActor.run { output.isLoading = false }
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
                limit: 50,
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
                // Gate onMessageReceived during initial sync
                self.isInitialSyncing = true
                await self.syncChatListIfNeeded()
                self.isInitialSyncing = false
                
                // Drain any buffered messages after sync completes
                if !self.bufferedSocketMessages.isEmpty {
                    let toProcess = self.bufferedSocketMessages
                    self.bufferedSocketMessages.removeAll()
                    for msg in toProcess {
                        await self.handleIncomingMessage(msg)
                    }
                }
            }
        }
        
        socketService.onMessageReceived = { [weak self] message in
            guard let self else { return }
            Task {
                // If syncing, buffer; else process immediately
                if self.isInitialSyncing {
                    self.bufferedSocketMessages.append(message)
                    return
                }
                
                // Dedup guard
                if self.alreadyHasMessage(message.chatID) {
                    return
                }
                
                await self.handleIncomingMessage(message)
                
            }
        }
    }
    
    
    
    
    // MARK: - Dedup Helper
    private func alreadyHasMessage(_ id: String) -> Bool {
        if chatMessageEntity.contains(where: { $0.chatID == id }) { return true }
        for group in output.groupedChatList {
            if group.messages.contains(where: { $0.chatID == id }) { return true }
        }
        return false
    }

    // MARK: - Handle Incoming Message (실시간 소켓 메시지 append)
    private func handleIncomingMessage(_ message: ChatEntity) async {
        await MainActor.run {
            // 중복 차단
            if alreadyHasMessage(message.chatID) {
                return
            }
            
            // Realm 저장
            chatUseCases.saveRealmMessages.execute(message: message, myID: userID)
            
            // UI append
            if !chatMessageEntity.contains(where: { $0.chatID == message.chatID }) {
                let model = message.toEntity(myID: userID)
                
                if !model.isMine {
                    self.output.newMessage = true
                }
                
                chatMessageEntity.append(model)
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
                    
                    let result = performLoadChatList()
                    output.groupedChatList = result
                    
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
            
            let existingIDs = Set(chatMessageEntity.map { $0.chatID })
            let filtered = chatList.filter { !existingIDs.contains($0.chatID) && !alreadyHasMessage($0.chatID) }
            
            let newMessages = filtered.map { $0.toEntity(myID: userID) }
            
            chatMessageEntity.append(contentsOf: newMessages)
            newMessages.forEach { appendToGroupedChatList($0) }
        }
    }
    
    // MARK: - Grouped Chat List Helper
    private func appendToGroupedChatList(_ message: ChatMessageEntity) {
        let date = Calendar.current.startOfDay(for: message.createdAt)
        if let index = output.groupedChatList.firstIndex(where: { $0.date == date }) {
            let exists = output.groupedChatList[index].messages.contains(where: { $0.chatID == message.chatID })
            if !exists {
                output.groupedChatList[index].messages.append(message)
                output.groupedChatList[index].messages = sortMessages(output.groupedChatList[index].messages)
            }
        } else {
            output.groupedChatList.append((date: date, messages: [message]))
            output.groupedChatList.sort { $0.date < $1.date }
        }
    }
    
    
    // MARK: 페이지네이션
    private func handelLoadChatList() {

        
        guard let earliest = output.groupedChatList
            .flatMap({ $0.messages })
            .min(by: { $0.createdAt < $1.createdAt }) else {return }
        
        fetchRealmChatList(date: earliest.createdAt)
    }
    
    private func fetchRealmChatList(date: Date) {
        guard !isLoadingMore else { return }

        let result = performLoadChatList(before: date)

        Task { @MainActor in
            
            for newGroup in result {
                if let idx = output.groupedChatList.firstIndex(where: { $0.date == newGroup.date }) {
            
                    let existingIDs = Set(output.groupedChatList[idx].messages.map { $0.chatID })
                    let deduped = newGroup.messages.filter { !existingIDs.contains($0.chatID) }
                    output.groupedChatList[idx].messages.append(contentsOf: deduped)
                    output.groupedChatList[idx].messages = sortMessages(output.groupedChatList[idx].messages)
                } else {
                    output.groupedChatList.append((date: newGroup.date, messages: sortMessages(newGroup.messages)))
                }
            
                let currentIDs = Set(chatMessageEntity.map { $0.chatID })
                let toAppend = newGroup.messages.filter { !currentIDs.contains($0.chatID) }
                chatMessageEntity.append(contentsOf: toAppend)
            }

            output.groupedChatList.sort { $0.date < $1.date }
            isLoadingMore = false
        }
    }
    
    func performLoadChatList(before: Date? = nil) -> [(date: Date, messages: [ChatMessageEntity])] {
        isLoadingMore = true

        
        let fetchedRaw = chatUseCases.fetchRealmMessageList.excute(
            roomID: roomID,
            before: before,
            limit: 50,
            myID: userID
        )
        
        let fetched: [ChatMessageEntity]
        if let boundary = before {
            fetched = fetchedRaw.filter { $0.createdAt < boundary }
        } else {
            fetched = fetchedRaw
        }
        
        var existingIDs = Set(chatMessageEntity.map { $0.chatID })
        for group in output.groupedChatList {
            for m in group.messages { existingIDs.insert(m.chatID) }
        }
        
        let newMessages = fetched.filter { !existingIDs.contains($0.chatID) }
        
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: newMessages) { calendar.startOfDay(for: $0.createdAt) }

        return grouped.sorted { $0.key < $1.key }.map { ($0.key, sortMessages($0.value)) }
    }
    
    
    /// 안전 정렬
    private func sortMessages(_ xs: [ChatMessageEntity]) -> [ChatMessageEntity] {
        xs.sorted { a, b in
            if a.createdAt != b.createdAt { return a.createdAt < b.createdAt }
            return a.chatID < b.chatID
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
    
    private func performSendMessage(content: String, imgase: [UIImage], file: URL? = nil) {
        Task {
            do {
                let fileUrls: [String]
                if imgase.isEmpty && file == nil {
                    fileUrls = []
                } else {
                    if let url = file {
                        fileUrls = await performUploadFile(roomID: roomID, url: url)
                    } else {
                        fileUrls = await performUploadImage(roomID: roomID, files: imgase)
                    }
                    
                    /// 업로드 실패 시
                    if fileUrls.isEmpty {
                        await MainActor.run {
                            output.presentedMessage = DisplayMessage.error(code: -1, msg: "파일/이미지 업로드 실패")
                        }
                        return
                    }
                    
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
            // 이미 존재하면(소켓 에코 등) 중복 방지
            if alreadyHasMessage(message.chatID) {
                selectedImages = []
                return
            }
            
            // Realm 저장
            chatUseCases.saveRealmMessages.execute(message: message, myID: userID)
            
            let model = message.toEntity(myID: userID)
            selectedImages = []
            
            if !chatMessageEntity.contains(where: { $0.chatID == model.chatID }) {
                chatMessageEntity.append(model)
            }
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
    
    // MARK: 파일 업로드
    private func handleFileUpload() {
        performSendMessage(content: "파일", imgase: [], file: selectedFileURL)
    }
    
    
    
    private func performUploadFile(roomID: String, url: URL) async -> [String] {
        do {
            let data = try await chatUseCases.uploadFile.execute(roodID: roomID, file: url)
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
        case sendFile
        case loadChatList
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .sendButtonTapped:
            handleSendButtonTapped()
        case .sendFile:
            handleFileUpload()
        case .loadChatList:
            handelLoadChatList()
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


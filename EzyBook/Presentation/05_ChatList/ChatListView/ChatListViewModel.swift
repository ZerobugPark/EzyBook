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
    
    private let chatRoomUseCases: ChatRoomListUseCases
    
    private let profileSearchUseCase: DefaultProfileSearchUseCase
    private let imageLoader: DefaultLoadImageUseCase
    
    private var userID: String {
        UserSession.shared.currentUser!.userID
    }
    
    init(
        chatRoomUseCases: ChatRoomListUseCases,
        profileSearchUseCase: DefaultProfileSearchUseCase,
        imageLoader: DefaultLoadImageUseCase
    ) {
        
        self.chatRoomUseCases = chatRoomUseCases
        self.profileSearchUseCase = profileSearchUseCase
        self.imageLoader = imageLoader
        
        
        transform()
    }
    
    
    deinit {
        
    }
}

// MARK: Input/Output
extension ChatListViewModel {
    
    struct Input {  }
    
    struct Output {
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
        
        var chatRoomList: [ChatRoomEntity] = []
        
        
        var opponentIndex: Int? = nil

    }
    
    func transform() {}
    
    
    private func requestChatRoomList() {
        
        loadChatRoomsFromRealm()
        Task { await loadChatRoomsFromServer() }
 
    }
        
    /// UI Update
    /// Realm에서 먼저 불러오기 (빠르게 UI 표시)
    private func loadChatRoomsFromRealm() {
        let realmData = chatRoomUseCases.fetchRealmChatRoomList.execute()
        if !realmData.isEmpty {
            output.chatRoomList = realmData
        }
    }

    
    /// 서버 호출
    private func loadChatRoomsFromServer() async {
        do {
            let remoteData = try await chatRoomUseCases.fetchRemoteChatRoomList.execute()
            let updatedData = await attachProfileImages(to: remoteData)
            
            await MainActor.run {
                output.chatRoomList = updatedData.filter { $0.lastChat != nil }
                chatRoomUseCases.saveRealmLastMessage.execute(lastChat: output.chatRoomList)
            }
        } catch let error as APIError {
            await MainActor.run {
                output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
            }
        } catch {
            print(#function,  "알 수 없는 오류")
        }
    }
    
    /// 이미지 로딩
    private func attachProfileImages(to data: [ChatRoomEntity]) async -> [ChatRoomEntity] {
        let profileImages = await loadProfileLookup(data)
        return data.enumerated().map { index, element in
            var item = element
            item.opponentImage = profileImages[index]
            return item
        }
    }

    
    
    
    //TODO: 채팅창이 많아지면 페이지 네이션 기능 추가해할 듯
    private func loadProfileLookup(_ data: [ChatRoomEntity]) async -> [UIImage?]  {
        
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            
            for (index, item) in data.enumerated() {
                
                group.addTask { [weak self] in
                    
                    guard let self else { return (-1, nil) }
                    
                    let image = await self.loadProfileImage(for: item)
                    
                    return (index, image)
                }
            }
            
            var images: [UIImage?] = .init(repeating: UIImage(), count: data.count)
            
            for await (index, image) in group {
                images[index] = image
            }
            
            return images
        }
        
        
    }
    
    
    //  이미지 로드
    private func loadProfileImage(for item: ChatRoomEntity) async -> UIImage? {
        do {
            
            guard let index = findOppentUserIndex(data: item) else { return nil }
            
            if let url = item.participants[index].profileImage {
                return try await imageLoader.execute(url)
            }
            return nil
        } catch let error as APIError {
            await MainActor.run {
                output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
            }
            
        } catch {
            print(#function,  "알 수 없는 오류")
        }
        return nil
    }
    
    private func findOppentUserIndex(data: ChatRoomEntity) -> Int? {
        if let opponentIndex = data.participants.firstIndex(where: { $0.userID != userID }) {
            
            output.opponentIndex = opponentIndex
            
            return opponentIndex
        }
        return nil
        
    }
    
    
    private func handleResetError() {
        output.presentedError = nil
    }
}

// MARK: Action
extension ChatListViewModel {
    
    enum Action {
        case showChatRoomList
        case resetError
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .showChatRoomList:
            requestChatRoomList()
        case .resetError:
            handleResetError()
        }
    }
    
    
}

//
//  ChatListViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 7/10/25.
//

import SwiftUI
import Combine

final class ChatListViewModel: ViewModelType {
    
    private var userID: String = ""
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    private var chatMessages: [ChatMessageEntity] = []
    private var scale: CGFloat = 0
    
    private let chatRoomRealmListUseCase: DefaultChatRoomRealmListUseCase
    private let chatRoomListUseCase: DefaultChatRoomListUseCase
    
    private let profileLookUpUseCase: DefaultProfileLookUpUseCase
    private let profileSearchUseCase: DefaultProfileSearchUseCase
    private let imageLoader: DefaultLoadImageUseCase
    
    init(
        chatRoomRealmListUseCase: DefaultChatRoomRealmListUseCase,
        chatRoomListUseCase: DefaultChatRoomListUseCase,
        profileLookUpUseCase: DefaultProfileLookUpUseCase,
        profileSearchUseCase: DefaultProfileSearchUseCase,
        imageLoader: DefaultLoadImageUseCase
    ) {

    
        self.chatRoomRealmListUseCase = chatRoomRealmListUseCase
        self.chatRoomListUseCase = chatRoomListUseCase
        self.profileLookUpUseCase = profileLookUpUseCase
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
    }
    
    func transform() {}
   
    
    private func requestChatRoomList() {
        
        
        /// Realm에서 먼저 불러오기 (빠르게 UI 표시)
        let realmData = chatRoomRealmListUseCase.excutFetchMessage()
        if !realmData.isEmpty {
            output.chatRoomList = realmData
        }
        
        /// 2. 서버에서 최신 채팅방 목록 불러오기 (갱신)
        Task {
            do {
                let data = try await chatRoomListUseCase.execute()
                let profileImages = await loadProfileLookup(data)
                
                let dataWithImage = data.enumerated().map { (offset, element) in
                    var item = element
                    item.opponentImage = profileImages[offset]
                    return item
                }

                await MainActor.run {
                    output.chatRoomList = dataWithImage.filter  { $0.lastChat != nil }
                    chatRoomRealmListUseCase.executeSaveData(lastChat: output.chatRoomList)
                }
                
            } catch let error as APIError {
                await MainActor.run {
                    output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
                }
                
            }
        }
        
        
    }
    
    
    
    //TODO: 채팅창이 많아지면 페이지 네이션 기능 추가해할 듯
    private func loadProfileLookup(_ data: [ChatRoomEntity]) async -> [UIImage?]  {
        
        
        await withTaskGroup(of: (Int, Result<UIImage?, Error>).self) { group in
            
            for (index, item) in data.enumerated() {
                
                group.addTask { [weak self] in
                    
                    guard let self else { return (-1, .failure(NSError(domain: "프로필 이미지 오류", code: -1)))}
                    
                    
                    let result: Result<UIImage?, Error>
                    
                    do {

                        let profileImage: UIImage?

                        if let url = item.participants[0].profileImage {
                            profileImage = try await imageLoader.execute(url)
                        } else  {
                            profileImage = nil
                        }
                        
                        result = .success(profileImage)
                        
                        
                    } catch {
                        result = .failure(error)
                    }
                    
                    return (index, result)
                }
            }
            
            var images: [UIImage?] = .init(repeating: UIImage(), count: data.count)
            
            for await (index, result) in group {
                switch result {
                case .success(let image):
                    images[index] = image
                case .failure(let error):
                    let error = error as? APIError
                    print("이미지 로드  실패 \(index): \(error?.userMessage ?? "알수 없는 오류")")
                    
                }
            }
            return images
        }
        
        
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

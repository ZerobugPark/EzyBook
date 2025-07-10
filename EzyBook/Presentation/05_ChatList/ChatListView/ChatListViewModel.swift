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
    
    private let chatListUseCase :DefaultChatListUseCase
    private let chatRealmUseCase: DefaultChatRealmUseCase
    private let chatRoomListUseCase: DefaultChatRoomListUseCase
    private let profileLookUpUseCase: DefaultProfileLookUpUseCase
    private let profileSearchUseCase: DefaultProfileSearchUseCase
    private let imageLoader: DefaultLoadImageUseCase
    
    init(
        chatListUseCase: DefaultChatListUseCase,
        chatRealmUseCase: DefaultChatRealmUseCase,
        chatRoomListUseCase: DefaultChatRoomListUseCase,
        profileLookUpUseCase: DefaultProfileLookUpUseCase,
        profileSearchUseCase: DefaultProfileSearchUseCase,
        imageLoader: DefaultLoadImageUseCase
    ) {

    
        self.chatListUseCase = chatListUseCase
        self.chatRealmUseCase = chatRealmUseCase
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
        
        //var opponentProfile: ProfileLookUpModel = .skeleton
        var chatRoomList: [ChatRoomEntity] = []
    }
    
    func transform() {}
    


//    private func loadProfileLookup() {
//        Task {
//            do {
//                let data = try await profileLookUpUseCase.execute()
//                userID = data.userID
//                
//                let opponentData = try await profileSearchUseCase.execute(opponentNick)
//                    
//                let profileImage: UIImage
//              
//                if let url = opponentData[0].profileImage {
//                    profileImage = try await imageLoader.execute(url)
//                } else  {
//                    profileImage = UIImage(resource: .tabBarProfileFill)
//                }
//                
//                await MainActor.run {
//                    output.opponentProfile = ProfileLookUpModel(from: opponentData[0], profileImage: profileImage)
//                }
//                
//                
//            } catch let error as APIError {
//                await MainActor.run {
//                    output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
//                }
//            }
//        }
//    }
    
    private func requestChatRoomList() {
        
        Task {
            do {
                let data = try await chatRoomListUseCase.execute()
 
                await MainActor.run {
                    output.chatRoomList = data.filter  { $0.lastChat != nil }
                    
                    print(data)

                }
                
                
            } catch {
                print(error)
            }
        }
        
        
    }
    
    
}

// MARK: Action
extension ChatListViewModel {
    
    enum Action {
        case showChatRoomList
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .showChatRoomList:
            requestChatRoomList()
        }
    }
    
    
}

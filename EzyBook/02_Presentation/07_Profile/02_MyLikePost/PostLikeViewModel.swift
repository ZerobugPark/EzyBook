//
//  PostLikeViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 8/10/25.
//

import SwiftUI
import Combine

final class PostLikeViewModel: ViewModelType {
    
    private let favoriteList: FavoriteServiceProtocol
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    
    private let limit = 10
    private var nextCursor: String?
    
    
    init(favoriteList: FavoriteServiceProtocol) {
        self.favoriteList = favoriteList
        
        transform()
        loadInitialLikePostList()
    }
    
}

// MARK: Input/Output
extension PostLikeViewModel {
    
    struct Input { }
    
    struct Output {
        
        var isLoading = true
        
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        
        var likeList: [PostSummaryEntity] = []
        
    }
    
    func transform() { }
    

    @MainActor
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            output.presentedMessage = DisplayMessage.error(code: apiError.code, msg: apiError.userMessage)
        } else {
            output.presentedMessage = DisplayMessage.error(code: -1, msg: error.localizedDescription)
        }
    }
    
    
}

extension PostLikeViewModel {
    
    /// Init 시점에서 호출
    private func loadInitialLikePostList() {
        Task {
            await MainActor.run { output.isLoading = true }
            
            await performfavoriteList()
            
            
            await MainActor.run {
                output.isLoading = false
                
            }
        }
    }

    private func performfavoriteList() async {
        do {
            
            let data = try await favoriteList.postLikeList(next: nextCursor, limit: String(limit))
            
            nextCursor = data.nextCursor
            
            await MainActor.run {
                output.likeList = data.data
            }
            
        } catch {
            await handleError(error)
        }
    }

    
    // MARK: 페이지네이션
    private func handleLikePaginationRequest() {
        
        Task {
            
            guard let nextCursor, nextCursor != "0" else { return }
            
            await MainActor.run { output.isLoading = true }
            
            await perfomPagination()
            
            await MainActor.run { output.isLoading = false }
            
        }
    }
    
    private func perfomPagination() async {
        do {
            
            let data = try await favoriteList.postLikeList(next: nextCursor, limit: String(limit))
            
            nextCursor = data.nextCursor
            
            await MainActor.run {
                output.likeList.append(contentsOf: data.data)
            }
            
        } catch {
            await handleError(error)
        }
    }
    
}

private extension PostLikeViewModel {
    
    
    func handleRemoveLike(_ postID: String) {
        Task {
            await performRemoveActivity(postID)
        }
    }
    
    func performRemoveActivity(_ postID: String) async {
        do {
            
            _ = try await favoriteList.postLike(postID: postID, status: false)
            
            
            await MainActor.run {
                if let index = output.likeList.firstIndex(where: { $0.postID == postID }) {
                    output.likeList.remove(at: index)
                }
            }
            
        } catch {
            await handleError(error)
        }
    }
}



// MARK: Action
extension PostLikeViewModel {
    
    enum Action {
        case paginationLikeList
        case removePost(postID: String)
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .paginationLikeList:
            handleLikePaginationRequest()
        case .removePost(let id):
            handleRemoveLike(id)
        }
    }
    
    
}


// MARK: Alert 처리
extension PostLikeViewModel: AnyObjectWithCommonUI {
    
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
    
}



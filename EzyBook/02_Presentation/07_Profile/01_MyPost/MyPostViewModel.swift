//
//  PostLikeViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 8/10/25.
//

import SwiftUI
import Combine

enum ProfilePostCategory {
    case myPost
    case likedPosts
    
    var title: String {
        switch self {
        case .myPost:
            return "내 게시글"
        case .likedPosts:
            return "게시글"
        }
    }
}

final class MyPostViewModel: ViewModelType {
    
    private let favoriteList: FavoriteServiceProtocol
    private let deleteUseCase: PostDeleteUseCase
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    
    private let limit = 10
    private var nextCursor: String?
    
    private var isPaginating = false
    
    let postCategory: ProfilePostCategory
    
    var userID: String {
        UserSession.shared.currentUser?.userID ?? ""
    }
    
    init(
        favoriteList: FavoriteServiceProtocol,
        postCategory: ProfilePostCategory,
        deleteUseCase: PostDeleteUseCase
    ) {
        self.favoriteList = favoriteList
        self.postCategory = postCategory
        self.deleteUseCase = deleteUseCase
        
        transform()
        
        if postCategory == .likedPosts {
            loadInitialLikePostList()
        } else {
            loadInitialMyPostList()
        }
        print(#function, Self.desc)
    }
    deinit {
        print(#function, Self.desc)
    }
}

// MARK: Input/Output
extension MyPostViewModel {
    
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


// MARK: 내 게시글

private extension MyPostViewModel {
    
    /// Init 시점에서 호출
    private func loadInitialMyPostList() {
        Task {
            await MainActor.run { output.isLoading = true }
            
            await performMyPostListList()
            
            
            await MainActor.run {
                output.isLoading = false
                
            }
        }
    }
    
    private func performMyPostListList() async {
        do {
            
            let data = try await favoriteList.myPostList(next: nextCursor, limit: String(limit), userID: userID)
            
            nextCursor = data.nextCursor
            
            await MainActor.run {
                output.likeList = data.data
            }
            
        } catch {
            await handleError(error)
        }
    }
    
    // MARK: 페이지네이션
    private func handlePostPaginationRequest(_ index: Int) {
        
        Task {
            
            
            guard !isPaginating else { return }
            
            let triggerIndex = max(0, output.likeList.count - 3)
            
            guard index >= triggerIndex else { return }
            
            guard let nextCursor, nextCursor != "0" else { return }
            
            await MainActor.run { output.isLoading = true }
            
            isPaginating = true
            
            await perfomMyPostPagination()
            
            isPaginating = false
            await MainActor.run { output.isLoading = false }
            
        }
    }
    
    private func perfomMyPostPagination() async {
        do {
            
            let data = try await favoriteList.myPostList(next: nextCursor, limit: String(limit), userID: userID)
            
            nextCursor = data.nextCursor
            
            await MainActor.run {
                output.likeList.append(contentsOf: data.data)
            }
            
        } catch {
            await handleError(error)
        }
    }
    
    // MARK: Post 삭제
    
    private func handleDeletePost(_ postID: String) {
        Task {
            await perfomDeletePost(postID)
        }
    }
    
    private func perfomDeletePost(_ postID: String) async {
        
        do {
            _ = try await deleteUseCase.execute(postID: postID)
            
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



// MARK: 내가 좋아하는 게시글
extension MyPostViewModel {
    
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
    private func handleLikePaginationRequest(_ index: Int) {
        
        Task {
            
            guard !isPaginating else { return }
            
            let triggerIndex = max(0, output.likeList.count - 3)
            
            guard index >= triggerIndex else { return }
            
            guard let nextCursor, nextCursor != "0" else { return }
            
            await MainActor.run { output.isLoading = true }
            
            isPaginating = true
            
            await perfomPagination()
            
            isPaginating = false
            
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
    
    
    /// 좋아요 취소
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

/// 수정된 내용 리턴
private extension MyPostViewModel {
    
    
    func handleModifiedPost(data: ModifyPost?) {
        guard let data else { return }
        
        Task {
            await modifedPostUpdate(data)
        }
    }
    
    @MainActor
    private func modifedPostUpdate(_ data: ModifyPost) {
        guard let index = output.likeList.firstIndex(where: { $0.postID == data.postID }) else { return }
        
        let prev = output.likeList[index]
        print("원본데이터", prev.files)
        // ModifyPost.files 가 옵셔널일 수 있으므로 안전 병합
        let mergedFiles = (data.files ?? prev.files)
        
        
        let modified = PostSummaryEntity(
            postID: data.postID,
            country: prev.country,
            category: prev.category,
            title: data.title,
            content: data.content,
            activity: prev.activity,
            geolocation: prev.geolocation,
            creator: prev.creator,
            files: mergedFiles,
            isLike: prev.isLike,
            likeCount: prev.likeCount,
            createdAt: prev.createdAt,
            updatedAt: prev.updatedAt
        )
        
        print("수정된 데이터", modified.files)
        output.likeList[index] = modified
    }
    
}



// MARK: Action
extension MyPostViewModel {
    
    enum Action {
        case pagination(index: Int)
        case cancelLike(postID: String)
        case deletePost(postID: String)
        case modifyPost(data: ModifyPost?)
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .pagination(let index):
            if postCategory == .likedPosts {
                handleLikePaginationRequest(index)
            } else {
                handlePostPaginationRequest(index)
            }
            
        case .cancelLike(let id):
            handleRemoveLike(id)
        case .deletePost(let postID):
            handleDeletePost(postID)
        case .modifyPost(let data):
            handleModifiedPost(data: data)
        }
    }
    
    
    
    
}


// MARK: Alert 처리
extension MyPostViewModel: AnyObjectWithCommonUI {
    
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
    
}



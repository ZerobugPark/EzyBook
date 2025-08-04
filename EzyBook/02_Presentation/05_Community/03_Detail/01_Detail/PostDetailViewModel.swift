//
//  PostDetailViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 8/3/25.
//

import SwiftUI
import Combine

final class PostDetailViewModel: ViewModelType {

    private let postDetailUseCase: PostDetailUseCase
    private let postService: PostFeatureService
    
    private(set) var postID: String
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    @Published var comment: String = ""
    
    init(
        postDetailUseCase: PostDetailUseCase,
        postService: PostFeatureService,
        postID: String
    ) {

        self.postDetailUseCase = postDetailUseCase
        self.postService = postService
        self.postID = postID
        
        loadInitialPostDetail()
        transform()
    }
    
    
}

// MARK: Input/Output
extension PostDetailViewModel {
    
    struct Input {  }
    
    struct Output {
        
        var isLoading = true
        
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        
        // Init
        var postDetailInfo: PostEntity = .skeleton
       
        
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
 
    
}


// MARK: Initial
private extension PostDetailViewModel {
    
    
    func loadInitialPostDetail() {
        Task {
            await MainActor.run {
                output.isLoading = true
            }
            await performLoadPostDetail(postID)
            
            await MainActor.run {
                output.isLoading = false
            }
        }
    }
    
    func performLoadPostDetail( _ postID:  String) async  {
        do {
            
            let detail = try await fetchPostDetail(postID)
            let sortedFiles = sortThumbnails(detail.files)
      
            await applyDetailOutput(detail: detail, files: sortedFiles)
        

        } catch {
            await handleError(error)
        }
    }
    
    /// 액티비티 상세 조회
    func fetchPostDetail(_ id: String) async throws -> PostEntity  {
        try await postDetailUseCase.execute(postID: id)
        
    }
    
    /// mp4가 먼저 오게 정렬
    /// lhs: left hand side
    /// rhs: reight hand side
    func sortThumbnails(_ thumbnails: [String]) -> [String] {
        thumbnails.sorted { lhs, rhs in
            let lhsIsMp4 = lhs.hasSuffix(".mp4")
            let rhsIsMp4 = rhs.hasSuffix(".mp4")
            return lhsIsMp4 && !rhsIsMp4
        }
    }
    
    
 

    // MARK: Main Actor: UIView Update
    @MainActor
    private func applyDetailOutput(detail: PostEntity, files: [String]) async {
            ///썸네일을 정렬 상태로  변경
            output.postDetailInfo = detail.with(files: files)
          
    }

}

// MARK: CRUD
private extension PostDetailViewModel {
    
    // MARK: Create
    private func hanldeWirteComment(parentID: String?) {
        Task {
            //await MainActor.run { output.isLoading = true }
            await performWriteComment(postID: postID, parentID: nil, content: comment)
            
            //await MainActor.run { output.isLoading = false }
        }
    }
    
    
    private func performWriteComment(postID: String, parentID: String?, content: String) async {
        do {
            
            let _ = try await  postService.write.writeComment(
                postID: postID,
                parentID: parentID,
                content: content
            )
        
            /// 누가 댓글 달았을 수도 있기 때문에 한 번 더 호출
            await performLoadPostDetail(postID)
            await MainActor.run {
                comment = ""
            }
            
        } catch {
            await handleError(error)
        }
    }
    
    // MARK: 답글
    private func hanldeWirteReplyComment(_ comment: CommentEntity, _ text: String) {
        Task {
            await performWriteComment(postID: postID, parentID: comment.commentID, content: text)
        }
    }
    
    
    
    // MARK: Deleted
    private func hanldeDeleteComment(_ commentID: String) {
        Task {
            await performDeleteComment(postID: postID, commentID: commentID)
        }
    }
    
    private func performDeleteComment(postID: String, commentID: String) async {
        do {
            
            try await postService.delete.deleteComment(
                postID: postID,
                commentID: commentID
            )

            /// 누가 댓글 달았을 수도 있기 때문에 한 번 더 호출
            await performLoadPostDetail(postID)
        
        } catch {
            await handleError(error)
        }
    }
    
    // MARK: Modify
    private func handleModifyComment(_ commentID: String, _ content: String) {
        Task {
            await perfomModifyComment(postID, commentID, content)
        }
    }
    
    private func perfomModifyComment(_ postID: String, _ commentID: String, _ content: String) async  {
        do {
            
            _ = try await postService.modify.modifyCommnet(postID: postID, commnetID: commentID, text: content)

            /// 누가 댓글 달았을 수도 있기 때문에 한 번 더 호출
            await performLoadPostDetail(postID)
        
        } catch {
            await handleError(error)
        }
    }

}


// MARK:  Keep Status
/// 좋아요 전용 뷰모델이나, useCase를 만들 수는 없을까?
extension PostDetailViewModel {
    
    
//    private func handleKeepButtonTapped() {
//        Task {
//            await performKeepActivity(activityID)
//        }
//    }
//    
//
//    private func performKeepActivity(_ id: String) async   {
//        
//        await MainActor.run {
//            output.activityDetailInfo.isKeep.toggle()
//        }
//  
//        do {
//            
//            let currentStatus = output.activityDetailInfo.isKeep
//            let status = try await favoirteService.activtyKeep(id: id, status: currentStatus)
//            
//            await MainActor.run {
//                output.activityDetailInfo.isKeep = status
//            }
//        } catch {
//            /// 실패시 원래대로 상태 변경
//            await MainActor.run {
//                output.activityDetailInfo.isKeep.toggle()
//            }
//        }
//    }
    
}




//// MARK: Action
extension PostDetailViewModel {
    
    enum Action {
        case keepButtonTapped
        case writeComment(parentID: String?)
        case deleteComment(commentID: String)
        case writeReply(comment: CommentEntity, text: String)
        case reloadData
        case modifyContent(commentID: String, text: String)

    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .keepButtonTapped:
            break
           // handleKeepButtonTapped()
 
        case .writeComment(let parentID):
            hanldeWirteComment(parentID: parentID)
        case .deleteComment(let commentID):
            hanldeDeleteComment(commentID)
        case let .writeReply(comment, text):
            hanldeWirteReplyComment(comment, text)
        case .reloadData:
            loadInitialPostDetail()
        case let .modifyContent(commentID, text):
            handleModifyComment(commentID, text)
        }
    }
        
}



// MARK: Alert 처리
extension PostDetailViewModel: AnyObjectWithCommonUI {
    
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
    
}


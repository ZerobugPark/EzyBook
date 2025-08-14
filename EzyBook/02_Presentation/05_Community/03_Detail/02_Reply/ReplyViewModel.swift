//
//  ReplyViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 8/4/25.
//

import SwiftUI
import Combine

final class ReplyViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()

    @Published var replyMessage: String = ""
    
    private var commentData: CommentEntity
    private let postService: PostFeatureService
    private let postID: String
    
    init(commentData: CommentEntity, postService: PostFeatureService,postID: String) {

        self.commentData = commentData
        self.postService = postService
        self.postID = postID
            
        output.commentInfo = commentData
        
        transform()
        
        print(#function, Self.desc)
    }
    
    
    deinit {
        print(#function, Self.desc)
    }
    
}

// MARK: Input/Output
extension ReplyViewModel {
    
    struct Input {  }
    
    struct Output {
        
        var isLoading = true
        
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        
        
        var commentInfo: CommentEntity?
        
        var onClosed = false
       
        
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


// MARK: CRUD
private extension ReplyViewModel {
 
    
    // MARK: 답글
    private func hanldeWirteReplyComment() {
        Task {
            await performWriteComment(postID: postID, parentID: commentData.commentID, content: replyMessage)
        }
    }
    
    
    private func performWriteComment(postID: String, parentID: String?, content: String) async {
        do {
            
            let data = try await  postService.write.writeComment(
                postID: postID,
                parentID: parentID,
                content: content
            )
        
            
            await MainActor.run {
                replyMessage = ""
                
                var temp = commentData
                temp.replies = [data]
                output.commentInfo = temp
                commentData = temp
                
            }
            
        } catch {
            await handleError(error)
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
            
            let _ = try await postService.delete.deleteComment(
                postID: postID,
                commentID: commentID
            )

            await MainActor.run {
                replyMessage = ""
                if commentID == output.commentInfo?.commentID {
                    // 부모 댓글 삭제
                    output.onClosed = true
                } else {
                    // 답글 삭제
                    output.commentInfo?.replies.removeAll(where: { $0.commentID == commentID })
                }
            }
            
            
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
            
            let data  = try await postService.modify.modifyCommnet(postID: postID, commnetID: commentID, text: content)

            await MainActor.run {
                var temp = commentData

                if commentID == temp.commentID {
                    temp = CommentEntity(
                        commentID: data.commentID,
                        content: data.content,
                        createdAt: data.createdAt,
                        creator: data.creator,
                        replies: temp.replies
                    )
                } else {
                    temp.replies = temp.replies.map { $0.commentID == commentID ? data : $0 }
                }
                
                output.commentInfo = temp
                commentData = temp
            }
           
        
        } catch {
            await handleError(error)
        }
    }
    
}




//// MARK: Action
extension ReplyViewModel {
    
    enum Action {
        case deleteComment(commentID: String)
        case writeReply
        case modifyContent(commentID: String, text: String)
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .deleteComment(let commentID):
            hanldeDeleteComment(commentID)
        case .writeReply:
            hanldeWirteReplyComment()
        case let .modifyContent(commentID, text):
            handleModifyComment(commentID, text)
        }
    }
        
}



// MARK: Alert 처리
extension ReplyViewModel: AnyObjectWithCommonUI {
    
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
    
}

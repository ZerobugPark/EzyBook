//
//  ReviewViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 7/31/25.
//

import SwiftUI
import Combine

final class ReviewViewModel: ViewModelType {
    
    private let activityID: String
    private let reviewUseCase: ActivityReviewLookUpUseCase
    private var nextCursor = ""
    var input = Input()
    @Published var output = Output()
    var cancellables = Set<AnyCancellable>()
        
    init(
        activityID: String,
        reviewUseCase: ActivityReviewLookUpUseCase)
    {
        self.activityID = activityID
        self.reviewUseCase = reviewUseCase
            
        loadInitialReviews(activityID)
        transform()
        
        print(#function, Self.desc)
    }
    
    deinit {
        print(#function, Self.desc)
    }
    
}

// MARK: Input/Output
extension ReviewViewModel {
    
    struct Input { }
    
    struct Output {
        
        var isLoading = false
        
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        
        var reviewList: [ReviewResponseEntity] = []
        
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

// MARK: 리뷰 관련
extension ReviewViewModel {
    
    private func loadInitialReviews(_ activityID: String) {
        Task {
            await MainActor.run { output.isLoading = true }
            await performReviewList(activityID)
            await MainActor.run { output.isLoading = false }
        }
    }
    
    
    
    private func performReviewList(_ activityID: String) async {
        do {
            let reviews = try await reviewUseCase.execute(activityID: activityID)
            nextCursor = reviews.nextCursor
            
            await MainActor.run {
                output.reviewList = reviews.data
            }
            
        } catch {
            await handleError(error)
        }
    }
    

}

// TODO: 페이지 네이션 기능 추가



// MARK: Alert 처리
extension ReviewViewModel: AnyObjectWithCommonUI {
    
    var isShowingError: Bool { output.isShowingMessage }
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
    
    
}

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




// MARK: 리뷰 데이터 (프리패치)
// 추후 데이터가 많아지면 기능 추가
extension ReviewViewModel {
    

//    // MARK: 프리패치
//    private func handleSearchListPrefetch(_ index: Int) {
//        Task {
//            await fetchSearchListNeeded(for: index)
//        }
//    }
//    
//    private func fetchSearchListNeeded(for index: Int) async {
//        let fetchIndex = index + 1
//
//        guard await shouldFetchSearchDetail(at: fetchIndex) else { return }
//
//        do {
//           // let detail = try await requestSearchDetail(at: fetchIndex)
//            //await updateSearchDetailUI(detail, at: fetchIndex)
//        } catch {
//            searchActivityindicats.remove(fetchIndex)
//            await handleError(error)
//        }
//    }
//    
//    @MainActor
//    private func shouldFetchSearchDetail(at index: Int) -> Bool {
//        if index < 0 || index >= searchActivitySummaryList.count {
//            print("🚨 Invalid index detected: \(index), listCount: \(searchActivitySummaryList.count)")
//            return false
//        }
//        if searchActivityindicats.contains(index) {
//            return false
//        }
//        searchActivityindicats.insert(index)
//        return true
//    }
//
////    private func requestSearchDetail(at index: Int) async throws -> FilterActivityModel {
////       // return try await reqeuestActivityDetailList(searchActivitySummaryList[index], type: FilterActivityModel.self)
////    }
//
//    @MainActor
//    private func updateSearchDetailUI(_ detail: FilterActivityModel, at index: Int) {
//        _searchActivityDetailList[index] = detail
//    }

}


//// MARK: Action
extension ReviewViewModel {
    
    enum Action {
    
        
        
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
    }
    
    
}

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


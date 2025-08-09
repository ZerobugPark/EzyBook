//
//  ReviewDetailViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 7/28/25.
//

import SwiftUI
import Combine

struct GroupedReview: Identifiable {
    var id: String { date }
    let date: String     // 표시용 (yyyy-MM-dd)
    let rawDate: Date    // 정렬용
    var reviews: [UserReviewDetailList]
}


final class ReviewDetailViewModel: ViewModelType {
    
    private let reviewUseCases: ReviewUseCases
    
    private let orderEntity: [OrderEntity] // 주입 시 rating이 nil인것은 제외
    private var reviewList: [UserReviewDetailList] = []
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    
    init(
        reviewUseCases: ReviewUseCases,
        orderList: [OrderEntity]
    ) {
        self.reviewUseCases = reviewUseCases
        self.orderEntity = orderList
        transform()
        
        handleLoadInitialReviewList()
        
    }
    
}

extension ReviewDetailViewModel {
    
    struct Input { }
    
    struct Output {
        var isLoading = false
        
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        /// 날짜별 그룹화
        var groupedReviewList: [GroupedReview] = []
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

extension ReviewDetailViewModel {
    
    
    // MARK: Order List Loading (SRP-refactored)
    /// Handles the initial loading of the order list, showing/hiding loading indicator.
    ///
    
    private func handleLoadInitialReviewList() {
        Task {
            await MainActor.run { output.isLoading = true }
            await performFetchOrderList(orderEntity)
            await MainActor.run { output.isLoading = false }
        }
    }

    /// Performs fetching the review list, including image loading and grouping.
    private func performFetchOrderList(_ data: [OrderEntity]) async {
        do {
            
            let reviewDetail = await performReivewDetail(data)
            
            
            let newReViewList = makeReviewDetailList(data: reviewDetail)
            
            reviewList = newReViewList
            let grouped = makeGroupeReviewList(from: reviewList)
            
            await MainActor.run {
                output.groupedReviewList = grouped
            }
        }
    }
    
    /// 리뷰 상세 조회
    private func performReivewDetail(_ data: [OrderEntity]) async -> [UserReviewEntity] {
        await withTaskGroup(of: UserReviewEntity?.self) { group in
            for item in data {
                group.addTask { [weak self] in
                    guard let self else { return nil }
                    do {
                        return try await reviewUseCases.reviewDetail.execute(
                            activityID: item.activity.id,
                            reviewID: item.review?.id ?? ""
                        )
                    } catch {
                        await self.handleError(error)
                        return nil
                    }
                }
            }

            var results: [UserReviewEntity] = []
            for await result in group {
                if let entity = result {
                    results.append(entity)
                }
            }

            return results
        }
    }
    
    

    /// UserReviewEntity -> UserReviewDetailModel 변환
    private func makeReviewDetailList(data: [UserReviewEntity]) -> [UserReviewDetailList] {
        data.map { UserReviewDetailList(dto: $0) }
    }

    /// 리뷰는 작성일 기준으로 표시
    /// [
    /// GroupedReview(date: "2025-07-28", reviews: [review1, review2]),
    ///GroupedReview(date: "2025-07-27", reviews: [review3]),
    /// GroupedReview(date: "2025-07-25", reviews: [review4, review5, review6])
    ///  ]
    private func makeGroupeReviewList(from reviewList: [UserReviewDetailList]) -> [GroupedReview] {
        let grouped = Dictionary(grouping: reviewList) { $0.createdAt.toDisplayDateTime() }
        return grouped.compactMap { key, reviews in
            guard let rawDate = reviews.first?.createdAt.toDate() else { return nil }
            return GroupedReview(date: key, rawDate: rawDate, reviews: reviews)
            
        }
        .sorted { $0.rawDate > $1.rawDate }
    }
}


// MARK: 리뷰 삭제
extension ReviewDetailViewModel {
    
    private func handleReviewDelete(_ data: UserReviewDetailList) {
        
        Task {
            await performDeleteReview(data)
        }
    }
    
    
    private func performDeleteReview(_ data: UserReviewDetailList) async {
        
        do {
            
            try await reviewUseCases.reviewDelete.execute(id: data.activityID, reviewID: data.reviewID)
            
            if let index =  reviewList.firstIndex(where: { $0.reviewID == data.reviewID }) {
                
                reviewList.remove(at: index)
            }
            
            let grouped = makeGroupeReviewList(from: reviewList)
            
            await MainActor.run {
                output.groupedReviewList = grouped
            }
            
        } catch {
            await handleError(error)
        }
        
    }
    
    
}

// MARK: 리뷰 수정
extension ReviewDetailViewModel {
    
    private func handleReviewModify(_ data: UserReviewDetailList?) {
        
        Task { @MainActor in
            performModifyReview(data)
        }
    }
    
    
    private func performModifyReview(_ data: UserReviewDetailList?)  {
        
        guard let data else { return }
        
        if let index =  reviewList.firstIndex(where: { $0.reviewID == data.reviewID }) {
            reviewList[index] = data
        }

        let grouped = makeGroupeReviewList(from: reviewList)
        output.groupedReviewList = grouped
        
        
    }
    
    
}


// MARK: Action
extension ReviewDetailViewModel {
    
    enum Action {
        case deleteReview(data: UserReviewDetailList)
        case modifyReview(data: UserReviewDetailList?)
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .deleteReview(let data):
            handleReviewDelete(data)
        case .modifyReview(let data):
            handleReviewModify(data)
        }
    }
}

// MARK: Alert 처리
extension ReviewDetailViewModel: AnyObjectWithCommonUI {
    
    var isShowingError: Bool { output.isShowingMessage }
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }

}



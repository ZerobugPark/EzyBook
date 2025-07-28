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
    
    private let imageLoadUseCases: ImageLoadUseCases
    private let reviewDetailUseCase: ReviewDetailUseCase
    
    private let orderEntity: [OrderEntity] // 주입 시 rating이 nil인것은 제외
    
    private var scale: CGFloat = 0 // 나중에 수정 필요
    
    private var reviewList: [UserReviewDetailList] = []
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    
    init(
        imageLoadUseCases: ImageLoadUseCases,
        reviewDetailUseCase: ReviewDetailUseCase,
        orderList: [OrderEntity],
        scale: CGFloat
    ) {
        self.imageLoadUseCases = imageLoadUseCases
        self.reviewDetailUseCase = reviewDetailUseCase
        self.orderEntity = orderList
        self.scale = scale
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
            let results = await performLoadImages(for: reviewDetail)
            
            let newReViewList = makeReviewDetailList(from: results, data: reviewDetail)
            
            reviewList = newReViewList
            
            
            let grouped = makeGroupeReviewList(from: reviewList)
            dump(grouped)
            
            await MainActor.run {
                output.groupedReviewList = grouped
            }
        }
    }
    
    private func performReivewDetail(_ data: [OrderEntity]) async -> [UserReviewEntity] {
        await withTaskGroup(of: UserReviewEntity?.self) { group in
            for item in data {
                group.addTask { [weak self] in
                    guard let self else { return nil }
                    do {
                        return try await reviewDetailUseCase.execute(
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
    
    
    /// Loads images in parallel for each review entity.
    private func performLoadImages(for data: [UserReviewEntity]) async -> [(Int, UIImage?)] {
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, item) in data.enumerated() {
                group.addTask { [weak self] in
                    guard let self else { return (index, nil) }
                    
                    guard item.reviewImageURLs.first != nil else {
                        return (index, nil)  // 이미지 없음 처리
                    }
                    do {
                        let image = try await self.requestThumbnailImage(item.reviewImageURLs[0])
                            return (index, image)
                        
                    } catch {
                        await self.handleError(error)
                        return (index, nil)
                    }
                }
            }

            var results = Array<(Int, UIImage?)>(repeating: (0, nil), count: data.count)

            for await result in group {
                results[result.0] = result
            }
            return results.sorted { $0.0 < $1.0 }
        }
    }

    /// UserReviewEntity -> UserReviewDetailModel 변환
    private func makeReviewDetailList(from results: [(Int, UIImage?)], data: [UserReviewEntity]) -> [UserReviewDetailList] {
        results.map {
            index,
            image in
            let item = data[index]
            return UserReviewDetailList(dto: item, image: image)

        }
    }

    /// 리뷰는 작성일 기준으로 표시
    /// [
    /// GroupedReview(date: "2025-07-28", reviews: [review1, review2]),
    ///GroupedReview(date: "2025-07-27", reviews: [review3]),
    /// GroupedReview(date: "2025-07-25", reviews: [review4, review5, review6])
    ///  ]
    private func makeGroupeReviewList(from reviewList: [UserReviewDetailList]) -> [GroupedReview] {
        let grouped = Dictionary(grouping: reviewList) { $0.createdAt.toDisplayDate() }
        return grouped.compactMap { key, reviews in
            guard let rawDate = reviews.first?.createdAt.toDate() else { return nil }
            return GroupedReview(date: key, rawDate: rawDate, reviews: reviews)
            
        }
        .sorted { $0.rawDate > $1.rawDate }
    }
}


// MARK: Helper

extension ReviewDetailViewModel {
    
//    private func handleUpdateReviewRating(_ orderCode: String, _ rating: Int) {
//        if let index = orderList.firstIndex(where: { $0.orderCode == orderCode }) {
//            orderList[index].rating = rating
//            output.groupedOrderList = makeGroupedOrderList(from: orderList)
//        }
//    }
    
    /// 이미지 로드 함수
    private func requestThumbnailImage(_ path: String) async throws -> UIImage {
        
        return try await imageLoadUseCases.thumbnailImage.execute(path: path, scale: scale)
        
    }
    
}

// MARK: Action
extension ReviewDetailViewModel {
    
    enum Action {
        case updateRating(orderCode: String, rating: Int)
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case let .updateRating(orderCode, rating):
            break
           // handleUpdateReviewRating(orderCode, rating)
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



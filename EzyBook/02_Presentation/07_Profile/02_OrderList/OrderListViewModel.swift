//
//  OrderListViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/19/25.
//

import SwiftUI
import Combine

struct GroupedOrder: Identifiable {
    var id: String { date }
    let date: String     // 표시용 (yyyy-MM-dd)
    let rawDate: Date    // 정렬용
    var orders: [OrderList]
}


final class OrderListViewModel: ViewModelType {
    
    private let imageLoadUseCases: ImageLoadUseCases
    private let orderEntity: [OrderEntity]
    
    private var scale: CGFloat = 0 // 나중에 수정 필요
    
    private var orderList: [OrderList] = []
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    
    init(
        imageLoadUseCases: ImageLoadUseCases,
        orderList: [OrderEntity],
        scale: CGFloat
    ) {
        self.imageLoadUseCases = imageLoadUseCases
        self.orderEntity = orderList
        self.scale = scale
        transform()
        
        handleLoadInitialOrderList()
        
    }
    
}

extension OrderListViewModel {
    
    struct Input { }
    
    struct Output {
        var isLoading = false
        
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        /// 날짜별 그룹화
        var groupedOrderList: [GroupedOrder] = []
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
    

    private func handleResetError() {
        output.presentedMessage = nil
    }
    
    
}

extension OrderListViewModel {
    
    
    // MARK: Order List Loading (SRP-refactored)
    /// Handles the initial loading of the order list, showing/hiding loading indicator.
    ///
    
    private func handleLoadInitialOrderList() {
        Task {
            await MainActor.run { output.isLoading = true }
            await performFetchOrderList(orderEntity)
            await MainActor.run { output.isLoading = false }
        }
    }

    /// Performs fetching the order list, including image loading and grouping.
    private func performFetchOrderList(_ data: [OrderEntity]) async {
        do {
            let results = await performLoadImages(for: data)
            let newOrderList = makeOrderList(from: results, data: data)
            
            orderList = newOrderList
            dump(orderList)
            let grouped = makeGroupedOrderList(from: newOrderList)

            await MainActor.run {
                output.groupedOrderList = grouped
            }
        }
    }

    /// Loads images in parallel for each order entity.
    private func performLoadImages(for data: [OrderEntity]) async -> [(Int, UIImage)] {
        await withTaskGroup(of: (Int, UIImage)?.self) { group in
            for (index, item) in data.enumerated() {
                group.addTask { [weak self] in
                    guard let self else { return nil }
                    do {
                        let image = try await self.requestThumbnailImage(item.activity.thumbnails[0])
                        return (index, image)
                    } catch {
                        await self.handleError(error)
                        return nil
                    }
                }
            }
            var results: [(Int, UIImage)] = []
            for await result in group {
                if let result = result {
                    results.append(result)
                }
            }
            return results.sorted { $0.0 < $1.0 }
        }
    }

    /// Pure function: creates an OrderList array from image results and order entities.
    private func makeOrderList(from results: [(Int, UIImage)], data: [OrderEntity]) -> [OrderList] {
        results.map { index, image in
            let item = data[index]
            return OrderList(
                orderID: item.orderId,
                orderCode: item.orderCode,
                activityID: item.activity.id,
                title: item.activity.title,
                country: item.activity.country,
                date: item.reservationItemName,
                time: item.reservationItemTime,
                rating: item.review?.rating,
                image: image,
                paidDate: item.paidAt
            )
        }
    }

    /// Pure function: groups OrderList by paid date, returns sorted GroupedOrder array.
    private func makeGroupedOrderList(from orderList: [OrderList]) -> [GroupedOrder] {
        let grouped = Dictionary(grouping: orderList) { $0.paidDate.toDisplayDate() }
        return grouped.compactMap { key, orders in
            guard let rawDate = orders.first?.paidDate.toDate() else { return nil }
            return GroupedOrder(date: key, rawDate: rawDate, orders: orders)
        }
        .sorted { $0.rawDate > $1.rawDate }
    }
}


// MARK: Helper

extension OrderListViewModel {
    
    private func handleUpdateReviewRating(_ orderCode: String, _ rating: Int) {
        if let index = orderList.firstIndex(where: { $0.orderCode == orderCode }) {
            orderList[index].rating = rating
            output.groupedOrderList = makeGroupedOrderList(from: orderList)
        }
    }
    
    /// 이미지 로드 함수
    private func requestThumbnailImage(_ path: String) async throws -> UIImage {
        
        return try await imageLoadUseCases.thumbnailImage.execute(path: path, scale: scale)
        
    }
    
}

// MARK: Action
extension OrderListViewModel {
    
    enum Action {
        case updateRating(orderCode: String, rating: Int)
        case resetError
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case let .updateRating(orderCode, rating):
            handleUpdateReviewRating(orderCode, rating)
        case .resetError:
            handleResetError()
            
        }
    }
    
    
}

// MARK: Alert 처리
extension OrderListViewModel: AnyObjectWithCommonUI {
    
    var isShowingError: Bool { output.isShowingMessage }
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }

}

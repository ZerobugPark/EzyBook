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
    
    private let orderEntity: [OrderEntity]
    
    private var orderList: [OrderList] = []
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    
    init(
        orderList: [OrderEntity]
    ) {
        self.orderEntity = orderList
        
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

            let newOrderList = makeOrderList(data: data)
            
            orderList = newOrderList

            let grouped = makeGroupedOrderList(from: newOrderList)

            await MainActor.run {
                output.groupedOrderList = grouped
            }
        }
    }


    /// Pure function: creates an OrderList array from image results and order entities.
    private func makeOrderList(data: [OrderEntity]) -> [OrderList] {
        return data.map { OrderList(entitiy: $0) }
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

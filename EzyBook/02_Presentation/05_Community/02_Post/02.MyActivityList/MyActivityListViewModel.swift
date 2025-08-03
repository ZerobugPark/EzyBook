//
//  MyActivityListViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 8/3/25.
//

import SwiftUI
import Combine


final class MyActivityListViewModel: ViewModelType {
    
    
    private let orderListUseCase: OrderListLookUpUseCase
    private let userWrittenPostListUseCase: UserWrittenPostListUseCase
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    
    init(
        orderListUseCase: OrderListLookUpUseCase,
        userWrittenPostListUseCase: UserWrittenPostListUseCase
    ) {
        self.orderListUseCase = orderListUseCase
        self.userWrittenPostListUseCase = userWrittenPostListUseCase
        transform()
        handleLoadInitialOrderList()
    }
    
}

extension MyActivityListViewModel {
    
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
    
    @MainActor
    private func handleSuccess() {
        output.presentedMessage = .success(msg: "액티비티 결제 내역이 없습니다.")
    }
    
}

extension MyActivityListViewModel {
    
    
    // MARK: Order List Loading (SRP-refactored)
    /// Handles the initial loading of the order list, showing/hiding loading indicator.
    ///
    
    private func handleLoadInitialOrderList() {
        Task {
            await MainActor.run { output.isLoading = true }
            let result = await performLoadOrderEntity()
            await performResultHandling(result)
            await MainActor.run { output.isLoading = false }
        }
    }
    
    private func performResultHandling(_ result: Result<[OrderEntity], Error>) async {
        switch result {
        case .success(let entity):
            if entity.isEmpty {
                await handleSuccess()
            } else {
                await performFetchOrderList(entity)
            }
        case .failure(let error):
            await handleError(error)
        }
    }
    
    
    private func performLoadOrderEntity() async -> Result<[OrderEntity], Error>  {
        do {
            let data = try await orderListUseCase.execute()
            return .success(data)
        } catch {
            return .failure(error)
            
        }
        
    }
    private func performFetchOrderList(_ data: [OrderEntity]) async {
        do {
            let filteredData = await filterOutWrittenActivities(from: data)
            let orderList = makeOrderList(data: filteredData)
            let grouped = makeGroupedOrderList(from: orderList)
            
            await MainActor.run {
                output.groupedOrderList = grouped
            }
        }
    }
    
    /// 렘에 저장된 activityID를 기준으로 필터링된 OrderEntity 배열 반환
    private func filterOutWrittenActivities(from entities: [OrderEntity]) async -> [OrderEntity] {
        
        let userID = await MainActor.run {
            UserSession.shared.currentUser?.userID
        }
        
        guard let userID else { return entities }
        
        do {
            let writtenIDs = try await userWrittenPostListUseCase.excute(userID: userID)
            return entities.filter { !writtenIDs.contains($0.activity.id) }
        } catch {
            return entities
        }
    }
    
    
    
    private func makeOrderList(data: [OrderEntity]) -> [OrderList] {
        return data.map { OrderList(entitiy: $0) }
    }
    
    
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
extension MyActivityListViewModel: AnyObjectWithCommonUI {
    
    var isShowingError: Bool { output.isShowingMessage }
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    var isSuccessMessage: Bool { output.presentedMessage?.isSuccess ?? false }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
    
}


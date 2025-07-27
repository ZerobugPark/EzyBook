//
//  OrderListViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/19/25.
//

import SwiftUI
import Combine

final class OrderListViewModel: ViewModelType {
    
    private let imageLoadUseCases: ImageLoadUseCases
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    private var scale: CGFloat = 0
    
    init(
        imageLoadUseCases: ImageLoadUseCases
    ) {
        self.imageLoadUseCases = imageLoadUseCases
        transform()
        
    }
    
}

extension OrderListViewModel {
    
    struct Input { }
    
    struct Output {
        var isLoading = false
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
        
        var orderList: [OrderList] = []
    }
    
    func transform() { }
    
    private func handleProfileData(_ data: [OrderEntity]) {
        Task {
            await MainActor.run {
                output.isLoading = true
            }
            
            await fetchOrderList(data)
            
            
            await MainActor.run {
                output.isLoading = false
                
            }
        }
    }
    
    
    private func fetchOrderList(_ data: [OrderEntity]) async {
        let results: [(Int, UIImage)] = await withTaskGroup(of: (Int, UIImage)?.self) { group in
            for (index, item) in data.enumerated() {
                group.addTask { [weak self] in
                    guard let self else { return nil }

                    do {
                        let image = try await self.requestThumbnailImage(item.activity.thumbnails[0])
                        return (index, image)
                    } catch {
                        /// 각 케이스마다 에러이긴 한데, 이러면 에러가 많이 발생할 때, Alert이 너무 많이 뜨지 않을까?
                        await self.handleError(error, index: index)
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

            return results.sorted(by: { $0.0 < $1.0 })
        }

        for (index, image) in results {
            let item = data[index]
            await MainActor.run {
                output.orderList.append(
                    OrderList(
                        orderID: item.orderId,
                        orderCode: item.orderCode,
                        activityID: item.activity.id,
                        title: item.activity.title,
                        country: item.activity.country,
                        date: item.reservationItemName,
                        time: item.reservationItemTime,
                        rating: item.review?.rating,
                        image: image
                    )
                )
            }
        }
    }

    

    /// 이미지 로드 함수
    private func requestThumbnailImage(_ path: String) async throws -> UIImage {
        
        return try await imageLoadUseCases.thumbnailImage.execute(path: path, scale: scale)
        
    }
    
    private func handleError(_ error: Error, index: Int) async {
        if let apiError = error as? APIError {
            await MainActor.run {
                output.presentedError = DisplayError.error(code: apiError.code, msg: apiError.userMessage)
            }
        } else {
            print("❌ 실패 \(index): 알 수 없는 오류")
        }
    }
    
    private func handleUpdateReviewRating(_ orderCode: String, _ rating: Int) {
        
        if let index = output.orderList.firstIndex(where: { $0.orderCode == orderCode }) {
            var updated = output.orderList[index]
            updated.rating = rating
            output.orderList[index] = updated
        }

        
    }

    
    
    private func handleResetError() {
        output.presentedError = nil
    }
    
    private func handleUpdateScale(_ scale: CGFloat) {
        self.scale = scale
    }
    
}

// MARK: Action
extension OrderListViewModel {
    
    enum Action {
        case onAppearRequested(data: [OrderEntity])
        case updateScale(scale: CGFloat)
        case updateRating(orderCode: String, rating: Int)
        case resetError
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .onAppearRequested(let data):
            handleProfileData(data)
        case .updateScale(let scale):
            handleUpdateScale(scale)
        case let .updateRating(orderCode, rating):
            handleUpdateReviewRating(orderCode, rating)
        case .resetError:
            handleResetError()
            
        }
    }
    
    
}


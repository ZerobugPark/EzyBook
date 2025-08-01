//
//  DetailViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/2/25.
//

import SwiftUI
import Combine

final class DetailViewModel: ViewModelType {
    
    private let activityUseCases: ActivityUseCases
    private let reviewLookupUseCase: ReviewRatingLookUpUseCase
    private let orderUseCase: CreateOrderUseCase
    private let chatService: ChatRoomServiceProtocol
    private let favoirteService: FavoriteServiceProtocol

    
    private(set) var activityID: String
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    
    init(
        activityUseCases: ActivityUseCases,
        reviewLookupUseCase: ReviewRatingLookUpUseCase,
        orderUseCaes: CreateOrderUseCase,
        chatService: ChatRoomServiceProtocol,
        favoirteService: FavoriteServiceProtocol,
        activityID: String
    ) {

        self.activityUseCases = activityUseCases
        self.reviewLookupUseCase = reviewLookupUseCase
        self.orderUseCase = orderUseCaes
        self.chatService = chatService
        self.favoirteService = favoirteService
        self.activityID = activityID
        
        loadInitialActivitiyDetail()
        transform()
    }
    
    
}

// MARK: Input/Output
extension DetailViewModel {
    
    struct Input {  }
    
    struct Output {
        
        var isLoading = true
        
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        
        // Init
        var activityDetailInfo: ActivityDetailEntity = .skeleton
        var reviews: ReviewRatingListEntity? = nil

        
        /// 결제
        var payItem: PayItem? = nil
        var payButtonTapped = false

        // 채팅
        var roomID: String? = nil
        
        // 판매자 ID
        var opponentNick: String {
            get {
                activityDetailInfo.creator.nick
            }
        }
        
        
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
    
    @MainActor
    private func handleSuccess(_ msg: DisplayMessage) {
        output.presentedMessage = msg
    }
    
}


// MARK: Initial
private extension DetailViewModel {
    
    
    func loadInitialActivitiyDetail() {
        Task {
            await MainActor.run {
                output.isLoading = true
            }
            await performLoadActivityDetail(activityID)
            
            await MainActor.run {
                output.isLoading = false
            }
        }
    }
    
    func performLoadActivityDetail( _ activityID:  String) async  {
        do {
            
            let detail = try await fetchActivityDetail(activityID)
            let sortedThumbnails = sortThumbnails(detail.thumbnailPaths)
            
            let reviews = try await requestReviews(activityID)
            
            await applyDetailOutput(detail: detail, thumbnails: sortedThumbnails, reviews:  reviews)
        

        } catch {
            await handleError(error)
        }
    }
    
    /// 액티비티 상세 조회
    func fetchActivityDetail(_ id: String) async throws -> ActivityDetailEntity  {
        try await activityUseCases.activityDetail.execute(id: id)
        
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
    
    
 
    /// 리뷰 요청
    private func requestReviews(_ id: String) async throws -> ReviewRatingListEntity {
        return try await reviewLookupUseCase.execute(id: id)
    }
    
    // MARK: Main Actor: UIView Update
    @MainActor
    private func applyDetailOutput(detail: ActivityDetailEntity, thumbnails: [String], reviews: ReviewRatingListEntity) async {
            ///썸네일을 정렬 상태로  변경
            output.activityDetailInfo = detail.with(thumbnails: thumbnails)
            output.reviews = reviews
    }

}


// MARK:  Keep Status
/// 좋아요 전용 뷰모델이나, useCase를 만들 수는 없을까?
extension DetailViewModel {
    
    
    private func handleKeepButtonTapped() {
        Task {
            await performKeepActivity(activityID)
        }
    }
    

    private func performKeepActivity(_ id: String) async   {
        
        await MainActor.run {
            output.activityDetailInfo.isKeep.toggle()
        }
  
        do {
            
            let currentStatus = output.activityDetailInfo.isKeep
            let status = try await favoirteService.activtyKeep(id: id, status: currentStatus)
            
            await MainActor.run {
                output.activityDetailInfo.isKeep = status
            }
        } catch {
            /// 실패시 원래대로 상태 변경
            await MainActor.run {
                output.activityDetailInfo.isKeep.toggle()
            }
        }
    }
    
}

// MARK: Order
extension DetailViewModel {
    /// 주문생성
    private func handleCreateOrder(_ id: String, _ name: String, _ time: String, _  count: Int, _ price: Int) {
        

        Task {
            await MainActor.run {
                output.isLoading = true
            }
            
            await performOrder(id, name, time, count, price)
            
            await MainActor.run {
                output.isLoading = false
            }
        }
    }
    
    private func performOrder(_ id: String, _ name: String, _ time: String, _  count: Int, _ price: Int) async {
        
        do {
            let detail = try await orderUseCase.execute(
                activityId: id,
                reservationItemName: name,
                reservationItemTime: time,
                participantCount: count,
                totalPrice: price
            )
                
            await presentPaymentSheet(detail: detail)
            
            
        } catch {
            await handleError(error)
        }
        
    }
    
    @MainActor
    private func presentPaymentSheet(detail: OrderCreateEntity)  {
        output.payItem = PayItem(orderCode: detail.orderCode, price: "\(detail.totalPrice)", name: output.activityDetailInfo.title)
        output.payButtonTapped = true
    }
    
    private func handleShowPaymentReulst(_ msg: DisplayMessage?) {
            
        let message = msg ?? .success(msg: "결제가 완료되었습니다.")

        Task {
            if msg == nil {
                // 다른 사람이 다른 시간대에 예약했을 수도 있기 때문에, 데이터의 정합성 위해 한 번더 API 호출
                loadInitialActivitiyDetail()
            }
            await handleSuccess(message)
        }
    }
    
    

}

// MARK:  Chat Button Tapped
extension DetailViewModel {
    
    private func handleMakeChatRoomTapped() {
        Task {
            await performCreateChatRoom()
        }
    }
    
    private func performCreateChatRoom() async {
        do {
            let id = output.activityDetailInfo.creator.userID
            let roomID = try await chatService.createOrGetRoomID(for: id)
            
            await MainActor.run {
                output.roomID = roomID
            }
            
        } catch {
            await handleError(error)
        }
    }
    
}




//// MARK: Action
extension DetailViewModel {
    
    enum Action {
        case keepButtonTapped
        case makeOrder(id: String, name: String, time: String, count: Int, price: Int)
        case showPaymentResult(message: DisplayMessage?)
        case makeChatRoom

    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .keepButtonTapped:
            handleKeepButtonTapped()
        case .showPaymentResult(let message):
            handleShowPaymentReulst(message)
        case .makeChatRoom:
            handleMakeChatRoomTapped()
        case let .makeOrder(id, name, time, count, price):
            handleCreateOrder(id, name, time, count, price)
 
        }
    }
        
}



// MARK: Alert 처리
extension DetailViewModel: AnyObjectWithCommonUI {
    
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
    
}

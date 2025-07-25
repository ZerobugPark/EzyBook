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
    private let reviewLookupUseCase: ReviewLookUpUseCase
    private let orderUseCase: CreateOrderUseCase
    private let createChatRoomUseCase: CreateChatRoomUseCase
    private let imageLoadUseCases: ImageLoadUseCases
    
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    private var scale: CGFloat = 0
      
    init(
        activityUseCases: ActivityUseCases,
        reviewLookupUseCase: ReviewLookUpUseCase,
        orderUseCaes: CreateOrderUseCase,
        createChatRoomUseCase: CreateChatRoomUseCase,
        imageLoadUseCases: ImageLoadUseCases
    ) {

        self.activityUseCases = activityUseCases
        self.reviewLookupUseCase = reviewLookupUseCase
        self.orderUseCase = orderUseCaes
        self.createChatRoomUseCase = createChatRoomUseCase
        self.imageLoadUseCases = imageLoadUseCases
        
        transform()
    }
    
    
}

// MARK: Input/Output
extension DetailViewModel {
    
    struct Input {  }
    
    struct Output {
        
        var isLoading = true
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
        
        var activityDetailInfo: ActivityDetailEntity = .skeleton
        var thumbnails: [UIImage] = []
        var reviews: ReviewRatingListEntity? = nil

        var hasMovieThumbnail = false
        
        var payItem: PayItem? = nil
        var payButtonTapped = false
        
        var roomID: String? = nil
        
        var opponentNick: String {
            get {
                activityDetailInfo.creator.nick
            }
        }
        
        
    }
    
    func transform() {}
    
    
    private func handleRequestActivityDetail(_  activityID:  String) {
        
        Task {
            do {
                let detail = try await reqeuestActivityDetailList(activityID)
                
                await MainActor.run {
                    output.activityDetailInfo = detail
                    
                }
            } catch let error as APIError {
                await MainActor.run {
                    output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
                }
            }
            
            await MainActor.run {
                output.isLoading = false
            }
        }
    }
    
    
        
    private func  reqeuestActivityDetailList(_ activityID:  String) async throws -> ActivityDetailEntity {
        
        var detail = try await activityUseCases.activityDetail.execute(id: activityID)
        
        
        let sortedThumbnails = detail.thumbnails.sorted {
            $0.hasSuffix(".mp4") && !$1.hasSuffix(".mp4")
        }
        
        detail.thumbnails = sortedThumbnails
        
        let images = try await requestThumbnailImages(sortedThumbnails)
        let hasMovie = detail.thumbnails.contains { $0.hasSuffix(".mp4") }
        let reviews = try await requestReviews(activityID)
        
        await MainActor.run {
            output.hasMovieThumbnail = hasMovie
            output.thumbnails = images
            output.reviews = reviews
        }

        return detail
        
    }
    
    private func requestThumbnailImages(_ paths: [String]) async throws -> [UIImage] {
        var imageDict: [String: UIImage] = [:]
        
        try await withThrowingTaskGroup(of: (String, UIImage).self) { group in
            for path in paths {
                group.addTask {
                    let image = try await self.requestThumbnailImage(path)
                    return (path, image)
                }
            }

            for try await (path, image) in group {
                imageDict[path] = image
            }
        }

        // original order 기반으로 정렬
        let sortedImages = paths.compactMap { imageDict[$0] }
        return sortedImages
    }

    
    private func requestThumbnailImage(_ path: String) async throws -> UIImage {
        
        return try await imageLoadUseCases.thumbnailImage.execute(path: path, scale: scale)
        
    }
    
    
    private func requestReviews(_ id: String) async throws -> ReviewRatingListEntity {
        return try await reviewLookupUseCase.execute(id: id)
    }
    
    private func handleResetError() {
        output.presentedError = nil
    }
    
    private func handleUpdateScale(_ scale: CGFloat) {
        self.scale = scale
    }
    
}




// MARK:  Keep Status
/// 좋아요 전용 뷰모델이나, useCase를 만들 수는 없을까?
extension DetailViewModel {
    private func triggerKeepActivity() {
        Task {
            await requestAcitivityKeep()
        }
    }
    
    /// 이거 채팅 생기면 Combine으로 처리 해야함 onAppear가 두번 발생할 수 있음
    /// 여기 메인액터로 묶는게 더 좋을까?
    private func requestAcitivityKeep() async   {
      
        
        await MainActor.run {
            output.activityDetailInfo.isKeep.toggle()
        }
  
        do {
            
            let detail = try await activityUseCases.activityKeepCommand.execute(
                id: output.activityDetailInfo.activityID,
                stauts: output.activityDetailInfo.isKeep
            )
            
            
            await MainActor.run {
                output.activityDetailInfo.isKeep = detail.keepStatus
            }
        } catch let error as APIError {
            await MainActor.run {
                output.activityDetailInfo.isKeep.toggle()
            }
            print(#function, error.userMessage)
        } catch {
            /// 실패시 원래대로 상태 변경
            await MainActor.run {
                output.activityDetailInfo.isKeep.toggle()
            }
        }
        
    }
    
    /// 주문생성
    private func handleRequestCreateOrder(_ id: String, _ name: String, _ time: String, _  count: Int, _ price: Int) {
        
        Task {
            do {
                let detail = try await orderUseCase.execute(
                    activityId: id,
                    reservationItemName: name,
                    reservationItemTime: time,
                    participantCount: count,
                    totalPrice: price
                )
                    
                await MainActor.run {
                    output.payItem = PayItem(orderCode: detail.orderCode, price: "\(detail.totalPrice)", name: output.activityDetailInfo.title)
                    output.payButtonTapped = true
                }
            } catch let error as APIError {
                await MainActor.run {
                    output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
                }
            }
            
            await MainActor.run {
                output.isLoading = false
            }
        }
    }
    
    private func handleShowPaymentReulst(_ msg: DisplayError?) {
        if let msg {
            output.presentedError = msg
        } else {
            output.presentedError = DisplayError.sucess(msg: "결제가 완료되었습니다.")
        }
    }
    
}


// MARK: makeChatRoom
extension DetailViewModel {
    
    private func handleCheckChatRoom() {
        
        Task {
            do {
                
                let id = output.activityDetailInfo.creator.userID
                let data = try await createChatRoomUseCase.execute(id: id)
                
                await MainActor.run {
                    output.roomID = data.roomID
                }
                
                
            } catch let error as APIError {
                await MainActor.run {
                    output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
                }
            } catch {
                print(error)
            }
        }
        
        print(output.activityDetailInfo.creator)
        
    }
}

//// MARK: Action
extension DetailViewModel {
    
    enum Action {
        case onAppearRequested(id: String)
        case updateScale(scale: CGFloat)
        case keepButtonTapped
        case makeOrder(id: String, name: String, time: String, count: Int, price: Int)
        case showPaymentResult(message: DisplayError?)
        case makeChatRoom
        case resetError
        
       
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .onAppearRequested(let id):
            handleRequestActivityDetail(id)
        case .updateScale(let scale):
            handleUpdateScale(scale)
        case .keepButtonTapped:
            triggerKeepActivity()
        case .resetError:
            handleResetError()
        case .showPaymentResult(let message):
            handleShowPaymentReulst(message)
        case .makeChatRoom:
            handleCheckChatRoom()
        case let .makeOrder(id, name, time, count, price):
            handleRequestCreateOrder(id, name, time, count, price)
 
        }
    }
    
    
}


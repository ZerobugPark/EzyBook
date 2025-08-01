//
//  WriteReviewViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/20/25.
//

import SwiftUI
import PhotosUI
import Combine

final class WriteReviewViewModel: ViewModelType {
    
    private let reviewUseCases: ReviewUseCases
    private let activityId: String
    let orderCode: String
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    
    init(reviewUseCases: ReviewUseCases,
         activityId: String,
         orderCode: String
    ) {
        self.reviewUseCases = reviewUseCases
        self.activityId = activityId
        self.orderCode = orderCode
        transform()
    }
    
}

extension WriteReviewViewModel {
    
    struct Input {
        var reviewText: String = ""
    }
    
    struct Output {
        
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
    }
    
    func transform() { }
    
    /// 이거 특정 뷰모델로 처리해도 괜찮지 않을까?
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
        output.presentedMessage = .success(msg: "리뷰가 성공적으로 작성되었습니다")
    }
    
    
}

extension WriteReviewViewModel {
    
    private func handleWriteReView(_ images: [UIImage],  _ rating: Int,) {
        
        Task {
            await performWriteReviewFlow(images, rating)
            
        }
        
        
    }
    
    private func performWriteReviewFlow(_ images: [UIImage], _ rating: Int) async {
        do {
            let paths = try await performUploadImages(id: activityId, images)
            try await performReview(id: activityId, rating: rating, serverPaths: paths, code: orderCode)
            
            await handleSuccess()
            
        } catch {
            await MainActor.run {
                handleError(error)
            }
        }
    }
    
    private func performUploadImages(id: String, _ images: [UIImage]) async throws -> [String]? {
        guard !images.isEmpty else { return nil }
        let path = try await requestUploadProfileImage(id: id, images)
        return path.reviewImageUrls
    }
    
    private func performReview(id: String, rating: Int, serverPaths: [String]?, code: String) async throws {
        _ = try await reviewUseCases.reviewWrite.execute(
            id: id,
            content: input.reviewText,
            rating: rating,
            reviewImageUrls: serverPaths,
            orderCode: code
        )
    }
    

    private func requestUploadProfileImage(id: String ,_ images: [UIImage]) async throws ->  ReviewImageEntity {
        return try await reviewUseCases.imageUpload.execute(id: id, images: images)
        
    }
    
    
}

// MARK: Action
extension WriteReviewViewModel {
    
    enum Action {
        case writeReView(images: [UIImage], rating: Int)
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {        case let .writeReView(images, rating):
            handleWriteReView(images, rating)
        }
    }
    
    
}

// MARK: Alert 처리
extension WriteReviewViewModel: AnyObjectWithCommonUI {
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    var isSuccessMessage: Bool { output.presentedMessage?.isSuccess ?? false }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
}



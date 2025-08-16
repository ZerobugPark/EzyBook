//
//  ReviewModifyViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 8/9/25.
//

import SwiftUI
import PhotosUI
import Combine

final class ReviewModifyViewModel: ViewModelType {
    
    private let reviewUseCases: ReviewUseCases
    
    private let reviewData: UserReviewDetailList
    
    @Published var reviewRating = 0
    @Published var selectedMedia: [PickerSelectedMedia] = []
    @Published var reviewText: String = ""
    
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    
    init(reviewUseCases: ReviewUseCases,
         reviewData: UserReviewDetailList
    ) {
        self.reviewUseCases = reviewUseCases
        self.reviewData = reviewData
        
        reviewText = reviewData.content
        reviewRating = reviewData.rating
        
        
        transform()
        
        
        print(#function, Self.desc)
        
    }
    
    deinit {
        print(#function, Self.desc)
    }
}

extension ReviewModifyViewModel {
    
    struct Input { }
    
    struct Output {
        
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        
        var resultModifyReviewData: UserReviewDetailList?
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
        output.presentedMessage = .success(msg: "리뷰가 성공적으로 수정되었습니다")
    }
    
    
}

extension ReviewModifyViewModel {
    
    private func handleModifyReView() {
        
        Task {
            
            let images = selectedMedia.filter{ $0.type == .image }.compactMap { $0.image }
            
            await performModifyReviewFlow(images, reviewRating)
            
        }
        
        
    }
    
    private func performModifyReviewFlow(_ images: [UIImage], _ rating: Int) async {
        do {
            
            let paths: [String]?
            if selectedMedia.isEmpty {
                paths = reviewData.reviewImageURLs
            } else {
                paths = try await performUploadImages(id: reviewData.activityID, images)
            }
            
            
            
            let data = try await performReview(id: reviewData.activityID, rating: rating, serverPaths: paths, reviewID: reviewData.reviewID)
            
            await MainActor.run {
                output.resultModifyReviewData = data
            }
            
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
    
    private func performReview(id: String, rating: Int?, serverPaths: [String]?, reviewID: String) async throws -> UserReviewDetailList {
        let data = try await reviewUseCases.reviewModify.execute(
            id: id,
            content: reviewText,
            rating: rating,
            reviewImageUrls: serverPaths,
            reviewID: reviewID
        )
        
         return UserReviewDetailList(dto: data)
        
    }
    

    private func requestUploadProfileImage(id: String ,_ images: [UIImage]) async throws ->  ReviewImageEntity {
        return try await reviewUseCases.imageUpload.execute(id: id, images: images)
        
    }
    
    
}

// MARK: Action
extension ReviewModifyViewModel {
    
    enum Action {
        case modifyReView
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .modifyReView:
            handleModifyReView()
        }
    }
    
    
}

// MARK: Alert 처리
extension ReviewModifyViewModel: AnyObjectWithCommonUI {
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    var isSuccessMessage: Bool { output.presentedMessage?.isSuccess ?? false }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
}




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
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    private var scale: CGFloat = 0
    
    init(reviewUseCases: ReviewUseCases) {
         self.reviewUseCases = reviewUseCases
         transform()
    }
    
}

extension WriteReviewViewModel {
    
    struct Input {
        var reviewText = ""
    
    }
    
    struct Output {
        var isLoading = false
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
        var writeSuccess: Bool = false
        
        var orderList: [OrderList] = []
    }
    
    func transform() { }
    
    
    private func writeActivityReView(_ id: String, _ images: [UIImage]?,  _ rating: Int, _ orderCode: String) {
        Task {
            await MainActor.run {
                output.isLoading = true
            }
            
          
            do {
                
                let serverPaths: [String]?
                
                if let images {
                    let path = try await requestUploadProfileImage(id: id, images)
                    serverPaths = path.reviewImageUrls
                } else {
                    serverPaths = nil
                }
                
                
                let dto = ReviewWriteRequestDTO(
                    content: input.reviewText,
                    rating: rating,
                    reviewImageUrls: serverPaths,
                    orderCode: orderCode
                )
                
                _ = try await  reviewUseCases.reviewWrite.execute(
                    id: id,
                    content: input.reviewText,
                    rating: rating,
                    reviewImageUrls: serverPaths,
                    orderCode: orderCode
                )
                
                await MainActor.run {
                    output.writeSuccess = true
                }
                
                

              } catch let error as APIError {
                  await MainActor.run {
                      output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
                  }
              } catch {
                  print(error)
              }
            
            await MainActor.run {
                output.isLoading = false
                
            }
        }
    }
    
    
    private func requestUploadProfileImage(id: String ,_ images: [UIImage]) async throws ->  ReviewImageEntity {
        return try await reviewUseCases.imageUpload.execute(id: id, images: images)
        
    }
    
    
    private func handleResetError() {
        output.presentedError = nil
    }
    
    private func handleUpdateScale(_ scale: CGFloat) {
        self.scale = scale
    }
    
}

// MARK: Action
extension WriteReviewViewModel {
    
    enum Action {
        case updateScale(scale: CGFloat)
        case writeReView(id: String,image: [UIImage]?, rating: Int, orderCode: String)
        case resetError
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .updateScale(let scale):
            handleUpdateScale(scale)
        case let .writeReView(id, images, rating, orderCode):
            writeActivityReView(id, images, rating, orderCode)
        case .resetError:
            handleResetError()
            
        }
    }
    
    
}



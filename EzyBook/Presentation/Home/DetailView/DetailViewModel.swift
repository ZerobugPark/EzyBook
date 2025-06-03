//
//  DetailViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/2/25.
//

import SwiftUI
import Combine

final class DetailViewModel: ViewModelType {
    
    private let activityDeatilUseCase: DefaultActivityDetailUseCase
    private let activityKeepCommandUseCase: DefaultActivityKeepCommandUseCase
    private let imageLoader: DefaultLoadImageUseCase
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    private var scale: CGFloat = 0
    
      
    init(
        activityDeatilUseCase: DefaultActivityDetailUseCase,
        activityKeepCommandUseCase: DefaultActivityKeepCommandUseCase,
        imageLoader: DefaultLoadImageUseCase
    ) {

        self.activityDeatilUseCase = activityDeatilUseCase
        self.activityKeepCommandUseCase = activityKeepCommandUseCase
        self.imageLoader = imageLoader
        
        transform()
    }
    
    
}

// MARK: Input/Output
extension DetailViewModel {
    
    struct Input {  }
    
    struct Output {
        
        var isLoading = false
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
        
        var activityDetailInfo: ActivityDetailEntity? = nil
    }
    
    func transform() {}
    
    
    private func handleRequestActivityDetail(_  activityID:  String) {
        
        Task {
            do {
                let detail = try await reqeuestActivityDetailList(activityID)
                await MainActor.run {
                    output.activityDetailInfo = detail
                    dump(output.activityDetailInfo)
                }
            } catch let error as APIError {
                await MainActor.run {
                    output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
                }
            }
        }
    }
    
    
        
    private func  reqeuestActivityDetailList(_ activityID:  String) async throws -> ActivityDetailEntity {
        
        let detail = try await self.activityDeatilUseCase.execute(id: activityID)
        //let thumbnailImage = try await self.requestThumbnailImage(detail.thumbnails)
        
        return detail
        
    }
    
    private func requestThumbnailImage(_ paths: [String]) async throws -> UIImage {
        
        let imagePaths = paths.filter {
            $0.hasSuffix(".jpg") || $0.hasSuffix(".png")
        }
        
        guard let path = imagePaths.first else {
            let fallback = UIImage(systemName: "star")!
            return fallback
        }
        return try await imageLoader.execute(path, scale: scale)
        
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
    
    /// 여기 메인액터로 묶는게 더 좋을까?
    private func requestAcitivityKeep() async   {
      
        
        guard let data = output.activityDetailInfo else {
            return
        }
        await MainActor.run {
            output.activityDetailInfo?.isKeep.toggle()
        }
  
        do {
            
            let detail = try await activityKeepCommandUseCase.execute(id: data.activityID, stauts: data.isKeep)
            
            await MainActor.run {
                output.activityDetailInfo?.isKeep = detail.keepStatus
            }
        } catch let error as APIError {
            await MainActor.run {
                output.activityDetailInfo?.isKeep.toggle()
            }
            print(#function, error.userMessage)
        } catch {
            /// 실패시 원래대로 상태 변경
            await MainActor.run {
                output.activityDetailInfo?.isKeep.toggle()
            }
        }
        
    }
}

//// MARK: Action
extension DetailViewModel {
    
    enum Action {
        case onAppearRequested(id: String)
        case updateScale(scale: CGFloat)
        case keepButtonTapped
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
            
      
        }
    }
    
    
}


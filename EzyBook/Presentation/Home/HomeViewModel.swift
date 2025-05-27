//
//  HomeViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import SwiftUI
import Combine

final class HomeViewModel: ViewModelType {
    
    private let activityListUseCase: DefaultActivityListUseCase
    private let activityNewLisUseCase: DefaultNewActivityListUseCase
    private let activityDeatilUseCase: DefaultActivityDetailUseCase
    
    private let imageLoader: DefaultLoadImageUseCase
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    private var scale: CGFloat = 0
    private let limit = 5
    private var nextCursor: String?
    
    init(
        activityListUseCase: DefaultActivityListUseCase,
        activityNewLisUsecaset: DefaultNewActivityListUseCase,
        activityDeatilUseCase: DefaultActivityDetailUseCase,
        imageLoader: DefaultLoadImageUseCase
    ) {
        self.activityListUseCase = activityListUseCase
        self.activityNewLisUseCase = activityNewLisUsecaset
        self.activityDeatilUseCase = activityDeatilUseCase
        self.imageLoader = imageLoader
        
        transform()
    }
    
    
}

// MARK: Input/Output
extension HomeViewModel {
    
    struct Input {
    }
    
    struct Output {
        
        var isLoading = true
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
        
        var acitivityNewDetailList: [NewActivityModel] = []
        
    }
    
    func transform() { }
    
    
    private func requestActivities(_ flag: Flag = .all, _ filter: Filter = .all) {
        
        let country = flag.requestValue
        let category =  filter.requestValue
        
        let requestDto = ActivitySummaryListRequestDTO(country: country, category: category, limit: "\(limit)", next: nextCursor)
        
        Task {
            do {
                /// async let:    비동기 작업 시작
                async let listResult = activityListUseCase.execute(requestDto: requestDto)
                async let newListResult = activityNewLisUseCase.execute(country: country, category: category)
                
                // 둘 다 성공해야 넘어감
                let (list, newList) = try await (listResult, newListResult)
                
                let details = try await reqeuestActivityDetailList(data: newList)
                
                await MainActor.run {
                    output.acitivityNewDetailList = details
                    output.isLoading = false
                }
            } catch let error as APIError {
                await MainActor.run {
                    output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
                }
            }
            
        }
    }
    
    private func reqeuestActivityDetailList(data:  [ActivitySummaryEntity]) async throws -> [NewActivityModel] {
        
        
        var result: [NewActivityModel] = []
        
        /// 순서가 보장이 되어야할까?
        for item in data {
            do {
                let detail = try await activityDeatilUseCase.execute(id: item.activityID)
                let thumnailImage = try await requestThumbnailImage(detail.thumbnails)
                
                
                let list = NewActivityModel(
                    activityID: detail.activityID,
                    title: detail.title,
                    country: detail.country,
                    thumnail: thumnailImage,
                    tag: detail.tags[0],
                    description: detail.description
                )
                
                result.append(list) // 순서 보장
            } catch {
                throw error
            }
        }
        
        return result
    }
    
    
    
    
    private func requestThumbnailImage(_ paths: [String]) async throws -> UIImage {
        
        let imagePaths = paths.filter {
            $0.hasSuffix(".jpg") // || $0.hasSuffix(".png")
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

// MARK: Action
extension HomeViewModel {
    
    enum Action {
        case onAppearRequested
        case updateScale(scale: CGFloat)
        case selectionChanged(flag: Flag, filter: Filter)
        case test
        case resetError
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case let .selectionChanged(flag, filter):
            requestActivities(flag, filter)
        case .updateScale(let scale):
            handleUpdateScale(scale)
        case .onAppearRequested:
            requestActivities()
        case .resetError:
            handleResetError()
        case .test:
            break
            //requestImage()
            
        }
    }
    
    
}

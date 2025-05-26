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
        imageLoader: DefaultLoadImageUseCase
    ) {
        self.activityListUseCase = activityListUseCase
        self.activityNewLisUseCase = activityNewLisUsecaset
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
        
        var newAcitivityList: [ActivitySummaryEntity] = []
        var outputData: UIImage = UIImage(systemName: "star")!
    }
    
    func transform() { }
    
    
    
//    private func requestActivities(_ flag: Flag = .all, _ filter: Filter = .all) {
//        
//        let country = flag.requestValue
//        let category =  filter.requestValue
//        
//        let requestDto = ActivitySummaryListRequestDTO(country: country, category: category, limit: "\(limit)", next: nextCursor)
//        
//        activityListUseCase.execute(requestDto: requestDto) { [weak self] result in
//            self?.handleResult(result)
//            
//        }
//        
//        activityNewLisUseCase.execute(country: country, category: category) { [weak self] result in
//            self?.handleResult(result)
//        }
//        
//        
//    }
    
    private func requestActivities(_ flag: Flag = .all, _ filter: Filter = .all) {
        
        let country = flag.requestValue
        let category =  filter.requestValue
        
        let requestDto = ActivitySummaryListRequestDTO(country: country, category: category, limit: "\(limit)", next: nextCursor)
        
        
        let listPublisher = activityListUseCase.executePulisher(requestDto: requestDto)
        
        let newListPublisher = activityNewLisUseCase.executePulisher(country: country, category: category)

        /// Zip, 둘 중에 하나만 실패해도 실패
        /// Error처리를 현재 Usecase에서 해주고 있어서 Combine이 더 낫다고 판단
        /// async let으로 사용할 경우 에러에 대한 핸들링을 뷰모델에서 해야하는데, 과연 그게 맞을까?
        Publishers.Zip(listPublisher, newListPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
                }
            } receiveValue: { [weak self] listResult, newListResult in
                //print(listResult)
                dump(newListResult)
                self?.output.newAcitivityList = newListResult
                self?.output.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    
    private func requestImage() {
        imageLoader.execute(output.newAcitivityList[0].thumbnails[1], scale: scale) { [weak self] result in
            switch result {
            case .success(let success):
                self?.output.outputData = success
            case .failure(let error):
                self?.output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
            }
        }
    }
    
    
//    private func handleResult<T>(_ result: Result<T, APIError>) {
//        
//        switch result {
//        case .success(let success):
//            break
//        case .failure(let error):
//            output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
//        }
//        
//    }
    
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
            requestImage()
  
        }
    }
    
    
}

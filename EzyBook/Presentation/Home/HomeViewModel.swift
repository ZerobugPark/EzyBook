//
//  HomeViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import SwiftUI
import Combine

final class HomeViewModel: ViewModelType {
    
    var activityListUseCase: DefaultActivityListUseCase
    var activityNewLisUsecaset: DefaultNewActivityListUseCase
    
    var input = Input()
    @Published var output = Output()
    
    
    var cancellables = Set<AnyCancellable>()
    
    private let limit = 5000
    private var nextCursor: String?
    
    init(activityListUseCase: DefaultActivityListUseCase, activityNewLisUsecaset: DefaultNewActivityListUseCase) {
        self.activityListUseCase = activityListUseCase
        self.activityNewLisUsecaset = activityNewLisUsecaset
        transform()
    }
    
    
}

// MARK: Input/Output
extension HomeViewModel {
    
    struct Input {
    }
    
    struct Output {
        
        var isLoading = false
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
    }
    
    func transform() { }
    
    
    
    private func handleSelectionResult(_ flag: Flag, _ filter: Filter) {
        
        let country = flag.requestValue
        let category =  filter.requestValue
        
        let requestDto = ActivitySummaryListRequestDTO(country: country, category: category, limit: "\(limit)", next: nextCursor)
        
        activityListUseCase.execute(requestDto: requestDto) { [weak self] result in
            switch result {
            case .success(let success):
                break
            case .failure(let error):
                self?.output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
            }
        }
    
    }
    
    private func handleLoadData() {
        
        
        let requestDto = ActivitySummaryListRequestDTO(country: nil, category: nil, limit: "\(limit)", next: nextCursor)
        
        activityListUseCase.execute(requestDto: requestDto) { [weak self] result in
            switch result {
            case .success(let success):
                self?.output.isLoading = true
                print("success")
            case .failure(let error):
                self?.output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
            }
        }
    }
    
    private func handlerResetError() {
        output.presentedError = nil
    }
    
}

// MARK: Action
extension HomeViewModel {
    
    enum Action {
        case onAppearRequested
        case selectionChanged(flag: Flag, filter: Filter)
        
        case resetError
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case let .selectionChanged(flag, filter):
            handleSelectionResult(flag, filter)
        case .onAppearRequested:
            handleLoadData()
        case .resetError:
            handlerResetError()
        
        }
    }
    
    
}

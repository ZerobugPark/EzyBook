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
    
    private let limit = 5
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
        let flageSelected: Flag = .all
        let filterSelected: Filter = .all
    }
    
    func transform() { }
    
    
    
    private func handleSelectionResult(_ flag: Flag, _ filter: Filter) {
        
        let country = flag.requestValue
        let category =  filter.requestValue
        
        let requestDto = ActivitySummaryListRequestDTO(country: country, category: category, limit: "\(limit)", next: nextCursor)
        
        activityListUseCase.execute(requestDto: requestDto) { result in
            switch result {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
        
        
    }
    

    
    //조합할 수 있는 무언가가 있어야겠는데?
    //    func networkTest() {
    //
    //        let data = ActivitySummaryListRequestDTO(country: "대한민국", category: "투어", limit: "5", next: nil)
    //
    //        container.activityListUseCase.execute(requestDto: data) { result in
    //            switch result {
    //            case .success(let success):
    //                print(success)
    //            case .failure(let failure):
    //                print(failure)
    //            }
    //        }
    //    }
    //
    //    func networkTest2() {
    //
    //        container.activityNewListUseCase.execute(country: "일본", category: "투어") { result in
    //            switch result {
    //            case .success(let success):
    //                print(success)
    //            case .failure(let failure):
    //                print(failure)
    //            }
    //        }
    //    }
    //
    //    //액티비티 검색
    //    func networkTest3() {
    //
    //
    //        container.activitySearchUseCase.execute(title: "스키")  { result in
    //            switch result {
    //            case .success(let success):
    //                print(success)
    //            case .failure(let failure):
    //                print(failure)
    //            }
    //        }
    //    }
}

// MARK: Action
extension HomeViewModel {
    
    enum Action {
        case selectionChanged(flag: Flag, filter: Filter)
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case let .selectionChanged(flag, filter):
            handleSelectionResult(flag, filter)
        }
    }
    
    
}

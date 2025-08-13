//
//  SearchViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 5/31/25.
//

import SwiftUI
import Combine

final class SearchViewModel: ViewModelType {
    
    private let activityUseCases: ActivityUseCases
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    
    /// Result Storage  Property
    /// 통신을 할 인덱스 관리 및 저장되는 데이터
    /// 검색 결과
    private var searchActivitySummaryList: [ActivitySummaryEntity] = [] // 서버 요청 데이터
    private var searchActivityindicats = Set<Int>()
    private var _searchActivityDetailList: [Int: FilterActivityModel] = [:] { // 화면에 보여줄 실제 상세 정보
        didSet {
            
            let sortedValues = _searchActivityDetailList
                .sorted { $0.key < $1.key }
                .map { $0.value }
            
            output.activitySearchDetailList = sortedValues
            
        }
    }
    
    
    
    init(activityUseCases: ActivityUseCases) {
        self.activityUseCases = activityUseCases
        transform()
        
        print("SearchVM init", ObjectIdentifier(self))
    }
    
    deinit {
        
        print("SearchVM deinit", ObjectIdentifier(self))
    }
    
    
}

// MARK: Input/Output
extension SearchViewModel {
    
    struct Input {
        var query = ""
        var searchButtonTapped = PassthroughSubject<String, Never>()
        
    }
    
    struct Output {
        
        var isLoading = false
        
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        
        var activitySearchDetailList: [FilterActivityModel] = []
        
    }
    
    func transform() {
        
        input.searchButtonTapped
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.handleSearchRequest(query)
            }
            .store(in: &cancellables)
        
    }
    
    
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

// MARK: 검색 관련
extension SearchViewModel {
    
    private func handleSearchRequest(_ query: String) {
        Task {
            await resetSearchState()
            await performSearchActivities(query)
            await stopLoading()
        }
    }
    
    @MainActor
    private func resetSearchState() {
        searchActivityindicats.removeAll()
        output.isLoading = true
    }
    
    
    private func performSearchActivities(_ query: String) async {
        do {
            let summary = try await activityUseCases.activitySearch.execute(title: query)
            let details = try await prefetchInitial(for: summary, type: FilterActivityModel.self)
            searchActivitySummaryList = summary
            await updateSearchUI(with: details)
        } catch {
            await handleError(error)
        }
    }
    
    @MainActor
    private func updateSearchUI(with details: [Int: FilterActivityModel]) {
        _searchActivityDetailList = [:]
        for (index, data) in details {
            _searchActivityDetailList[index] = data
        }
    }
    
    @MainActor
    private func stopLoading() {
        output.isLoading = false
    }
    
    
    /// 상세보기 항목 몇개만 미리 가져오기
    private func prefetchInitial<T: ActivityModelBuildable>(for list: [ActivitySummaryEntity], type: T.Type) async throws -> [Int: T] {
        var result: [Int: T] = [:]
        for i in 0..<min(3, list.count) {
            let detail = try await reqeuestActivityDetailList(list[i], type: T.self)
            result[i] = detail
            
            searchActivityindicats.insert(i)
        }
        return result
    }
    
    /// prefetch쪽을 공통 뷰모델로 관리해볼까?
    private func  reqeuestActivityDetailList<T: ActivityModelBuildable>(_ data:  ActivitySummaryEntity, type: T.Type) async throws -> T {
        
        let detail = try await activityUseCases.activityDetail.execute(id: data.activityID)
       
        return T(from: detail)
        
    }
    
    
}




// MARK: 검색 데이터 (프리패치)
extension SearchViewModel {
    

    // MARK: 프리패치
    private func handleSearchListPrefetch(_ index: Int) {
        Task {
            await fetchSearchListNeeded(for: index)
        }
    }
    
    private func fetchSearchListNeeded(for index: Int) async {
        let fetchIndex = index + 1

        guard await shouldFetchSearchDetail(at: fetchIndex) else { return }

        do {
            let detail = try await requestSearchDetail(at: fetchIndex)
            await updateSearchDetailUI(detail, at: fetchIndex)
        } catch {
            searchActivityindicats.remove(fetchIndex)
            await handleError(error)
        }
    }
    
    @MainActor
    private func shouldFetchSearchDetail(at index: Int) -> Bool {
        if index < 0 || index >= searchActivitySummaryList.count {
            print("🚨 Invalid index detected: \(index), listCount: \(searchActivitySummaryList.count)")
            return false
        }
        if searchActivityindicats.contains(index) {
            return false
        }
        searchActivityindicats.insert(index)
        return true
    }

    private func requestSearchDetail(at index: Int) async throws -> FilterActivityModel {
        return try await reqeuestActivityDetailList(searchActivitySummaryList[index], type: FilterActivityModel.self)
    }

    @MainActor
    private func updateSearchDetailUI(_ detail: FilterActivityModel, at index: Int) {
        _searchActivityDetailList[index] = detail
    }

}

// MARK: Banner
extension SearchViewModel {
    
    private func handleBannerResult(msg: String) {
        
        let result = DisplayMessage.success(msg: "\(msg)번째 출석이 완료되었습니다.")
        
        Task {
            await handleSuccess(result)
        }
        
    }
}



// MARK: Action
extension SearchViewModel {
    
    enum Action {
        case searchButtonTapped
        case prefetchSearchContent(index: Int)
        case bannerResult(msg: String)
        
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .searchButtonTapped:
            if input.query.isEmpty {
                output.presentedMessage = DisplayMessage.error(code: -1, msg: "공백 제외\n1글자 이상 입렵해주세요")
                return
            }
            let _query = input.query.trimmingCharacters(in: .whitespaces)
            input.searchButtonTapped.send(_query)

        case .prefetchSearchContent(let index):
            handleSearchListPrefetch(index)
        case .bannerResult(let msg):
            handleBannerResult(msg: msg)
        }
    }
    
    
}

// MARK: Alert 처리
extension SearchViewModel: AnyObjectWithCommonUI {
    
    var isShowingError: Bool { output.isShowingMessage }
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
    
    
}

//
//  HomeViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 5/25/25.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

final class HomeViewModel: ViewModelType {
    
    private let activityUseCases: ActivityUseCases
    private let imageLoadUseCases: ImageLoadUseCases
    private var scale: CGFloat
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    
    private let limit = 10
    private var nextCursor: String?
    private var paginationInProgress = false //페이지네이션 진행중 여부
    
    
    
    @Published var selectedFlag: Flag = .all
    @Published var selectedFilter: Filter = .all
    
    /// Result Storage  Property
    /// 통신을 할 인덱스 관리 및 저장되는 데이터
    
    private var newActivitySummaryList: [ActivitySummaryEntity] = [] // 서버 요청 데이터
    private var newActivityindicats = Set<Int>()
    private var _activityNewDetailList: [Int: NewActivityModel] = [:] { // 화면에 보여줄 실제 상세 정보
        didSet {
            
            let sortedValues = _activityNewDetailList
                .sorted { $0.key < $1.key }
                .map { $0.value }
            
            output.activityNewDetailList = sortedValues
        }
    }
    
    
    private var filterActivitySummaryList: [ActivitySummaryEntity] = [] // 서버 요청 데이터
    private var filterActivityindicats = Set<Int>()
    private var _filterActivityDetailList: [Int: FilterActivityModel] = [:] { // 화면에 보여줄 실제 상세 정보
        didSet {
            let sortedValues = _filterActivityDetailList
                .sorted { $0.key < $1.key }
                .map { $0.value }
            
            output.filterActivityDetailList = sortedValues
            
        }
    }
    private var pendingFetchIndices = Set<Int>() // 스크롤 펜딩
    
    
    
    
    init(
        activityUseCases: ActivityUseCases,
        imageLoadUseCases: ImageLoadUseCases,
        scale: CGFloat
    ) {
        self.activityUseCases = activityUseCases
        self.imageLoadUseCases = imageLoadUseCases
        self.scale = scale
        
        
        
        loadInitialActivities(selectedFlag, selectedFilter)
        
        transform()
    }
    
    
}

// MARK: Input/Output
extension HomeViewModel {
    
    struct Input { }
    
    struct Output {
        
        var isLoading = true
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
        
        var activityNewDetailList: [NewActivityModel] = []
        var filterActivityDetailList: [FilterActivityModel] = []
        
        
    }
    
    func transform() { }
    
    
    
    /// Init 시점에서 호출
    private func loadInitialActivities(_ flag: Flag, _ filter: Filter) {
        Task {
            await MainActor.run {
                output.isLoading = true
                newActivityindicats.removeAll() // Set indicats 초기화
                filterActivityindicats.removeAll() // Set indicats 초기화
                
            }
            await performNewActivityLoad(flag.requestValue, filter.requestValue)
            await performInitialFilterActivitiesLoad(flag.requestValue, filter.requestValue)
            
            await MainActor.run {
                output.isLoading = false
                
            }
        }
    }
    
    private func handleResetError() {
        output.presentedError = nil
    }
    
    @MainActor
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            output.presentedError = DisplayError.error(code: apiError.code, msg: apiError.userMessage)
        } else {
            output.presentedError = DisplayError.error(code: -1, msg: error.localizedDescription)
        }
    }
    
    
}

// MARK: New Activity 관련
extension HomeViewModel {
    
    /// 신규 액티비티 조회
    private func performNewActivityLoad(_ country: String?, _ category: String?) async {
        do {
            let summary = try await activityUseCases.activityNewList.execute(country: country, category: category)
            let details = try await prefetchInitial(for: summary, type: NewActivityModel.self)
            
            newActivitySummaryList = summary
            
            await MainActor.run {
                /// 데이터 초기화
                _activityNewDetailList = [:]
                for (index, data)in details {
                    _activityNewDetailList[index] = data
                }
                
            }
        } catch {
            await handleError(error)
        }
    }
    
    
    /// 프리패치
    private func handlePrefetchNewContent(_ index: Int) {
        Task {
            await fetchNewDetailIfNeeded(for: index)
        }
    }
    
    // 캐러셀이 이동하면 호출
    private func fetchNewDetailIfNeeded(for index: Int) async   {
        /// +2, 최초 로딩시, 3개의 [0, 1,  2]데이터를 가져옴, 이후 1번 인덱스에도착하면 3번 데이터를 호출
        let fetchIndex = index + 1
        
        
        guard shouldFetchNewDetail(at: fetchIndex) else { return }
        
        do {
            let detail = try await reqeuestActivityDetailList(newActivitySummaryList[fetchIndex], type: NewActivityModel.self)
            await updateNewActivityDetail(detail, at: fetchIndex)
            
        } catch  {
            newActivityindicats.remove(fetchIndex)
            await handleError(error)
        }
        
    }
    
    /// 중복 방지(Set 사용)  및, 데이터 양 체크, 요청 예약
    private func shouldFetchNewDetail(at index: Int) -> Bool {
        guard !newActivityindicats.contains(index), index < newActivitySummaryList.count else { return false }
        newActivityindicats.insert(index)
        return true
    }
    
    @MainActor
    private func updateNewActivityDetail(_ detail: NewActivityModel, at index: Int) {
        _activityNewDetailList[index] = detail
    }
    
    
    
}

// MARK: Filter 관련
extension HomeViewModel {
    
    ///  필터 데이터 조회
    private func performInitialFilterActivitiesLoad(_ country: String?, _ category: String?) async {
        do {
            let uniqueList = try await fetchUniqueFilterActivities(country: country, category: category)
            let details = try await prefetchInitial(for: uniqueList, type: FilterActivityModel.self)
            await updateFilterActivitiesUI(with: details)
        } catch {
            await handleError(error)
        }
    }

    private func fetchUniqueFilterActivities(country: String?, category: String?) async throws -> [ActivitySummaryEntity] {
        let summary = try await activityUseCases.activityList.execute(
            country: country,
            category: category,
            limit:"\(limit)",
            next: nil
        )
        nextCursor = summary.nextCursor
        filterActivitySummaryList = summary.data
        return removeNewActivitiesFromFilterList(filterList: summary.data)
    }
    
    
    @MainActor
    private func updateFilterActivitiesUI(with details: [Int: FilterActivityModel]) {
        _filterActivityDetailList = [:]
        for (index, data) in details {
            _filterActivityDetailList[index] = data
        }
    }
    
    
    /// New 있으면 필터에는 보이지 않게 하기 위한 중복제거 함수
    private func removeNewActivitiesFromFilterList(filterList: [ActivitySummaryEntity]) -> [ActivitySummaryEntity] {
        
        /// Set으로 만들어 시간복잡도를 줄임 (Set : O(1), Array: O(n)
        let newIDs = Set(newActivitySummaryList.map { $0.activityID })
        
        let filteredList = filterList.filter {
            !newIDs.contains($0.activityID)
        }
        
        return filteredList
    }
    

    
    private func prefetchInitial<T: ActivityModelBuildable>(for list: [ActivitySummaryEntity], type: T.Type) async throws -> [Int: T] {
        var result: [Int: T] = [:]
        for i in 0..<min(3, list.count) {
            let detail = try await reqeuestActivityDetailList(list[i], type: T.self)
            result[i] = detail
            
            if type == NewActivityModel.self {
                newActivityindicats.insert(i)
            } else if type == FilterActivityModel.self {
                filterActivityindicats.insert(i)
            }
            
        }
        return result
    }
    

    
    /// 필터 버튼 선택
    private func handleSelectionChanged(_ flag: Flag, _ filter: Filter) {
        Task {
            await MainActor.run {
                output.isLoading = true
                filterActivityindicats.removeAll() // Set indicats 초기화
                
            }
            await performInitialFilterActivitiesLoad(flag.requestValue, filter.requestValue)
            
            await MainActor.run {
                output.isLoading = false
                
            }
        }
    }
    
    
    // MARK: PreFecth
    private func handleFilterDetailPrefetch(_ index: Int) {
        Task {
            await fetchFilterDetailIfNeeded(for: index)
        }
    }
    
    ///필터가 OnAppear 될 때마다 호출
    ///prefetch: 상세 데이터 미리 불러오기
    private func fetchFilterDetailIfNeeded(for index: Int) async   {
        /// +1, 최초 로딩시, 3개의 [0, 1,  2]데이터를 가져옴, 이후 2번 인덱스에도착하면 3번 데이터를 호출
        let fetchIndex = index + 1
        
        /// prefetch 인덱스가, 실제 서버 에서 받은 데이터보다 크다면, 펜딩에 대기
        if shouldPendFetch(for: fetchIndex) { return }
        
        /// 페이지네이션 여부 또는 이미 요청 보냈는지 등 체크
        guard shouldFetchFilterDetail(at: fetchIndex) else { return }
        
        
        do {
            let detail = try await reqeuestActivityDetailList(filterActivitySummaryList[fetchIndex], type: FilterActivityModel.self)
            await MainActor.run {
                _filterActivityDetailList[fetchIndex] = detail
            }
        } catch {
            // 요청 실패 시 Set에서 제거
            filterActivityindicats.remove(fetchIndex)
            await handleError(error)
        }
        
    }
    
   
    private func shouldPendFetch(for index: Int) -> Bool {
        if index >= filterActivitySummaryList.count {
            pendingFetchIndices.insert(index)
            return true
        }
        return false
    }
    
    
    
    private func shouldFetchFilterDetail(at index: Int) -> Bool {
        guard !paginationInProgress,
              !filterActivityindicats.contains(index),
              index < filterActivitySummaryList.count else { return false }
        filterActivityindicats.insert(index)
        return true
    }

    
    
    // MARK: 페이지네이션
    private func handleFilterPaginationRequest(index: Int) {
        Task {
            await performFilterPaginationLoad(for: index)
        }
    }
    /// Pagination: 다음 페이지 요청
    private func performFilterPaginationLoad(for index: Int) async {
        guard shouldPerformFilterPagination(for: index) else { return }
        paginationInProgress = true
        defer { paginationInProgress = false }

        do {
            try await fetchAndAppendFilterActivities()
            await processPendingFilterPrefetches()
        } catch {
            await handleError(error)
        }
    }
    
    private func shouldPerformFilterPagination(for index: Int) -> Bool {
        let threshold = 2
        return !paginationInProgress &&
               index >= filterActivitySummaryList.count - threshold &&
               nextCursor != nil
    }
    
    private func fetchAndAppendFilterActivities() async throws {
        guard let nextCursor else { return }
        let summary = try await activityUseCases.activityList.execute(
            country: selectedFlag.requestValue,
            category: selectedFilter.requestValue,
            limit: "\(limit)",
            next: nextCursor
        )
        let uniqueList = removeNewActivitiesFromFilterList(filterList: summary.data)
        filterActivitySummaryList.append(contentsOf: uniqueList)
        self.nextCursor = summary.nextCursor
    }

    
    // MARK: TODO: 에러처리 시퀀스 추가 해야함 withTaskGroup은 에러처리가 불가능
    /// 펜딩에 많이 있을 수 있으니 withTaskGroup으로 동시에 데이터 처리
    private func processPendingFilterPrefetches() async {
        await withTaskGroup(of: (Int, Result<FilterActivityModel, Error>).self) { group in
            for index in pendingFetchIndices {
                guard index < filterActivitySummaryList.count,
                      !filterActivityindicats.contains(index) else { continue }
                
                filterActivityindicats.insert(index)
                
                group.addTask { [weak self] in
                    
                    guard let self else {
                        return (index, .failure(NSError(domain: "SelfDeallocated", code: -1)))
                    }
                    
                    let result: Result<FilterActivityModel, Error>
                    
                    do {
                        let detail = try await reqeuestActivityDetailList(
                            filterActivitySummaryList[index],
                            type: FilterActivityModel.self
                        )
                        result = .success(detail)
                    } catch {
                        result = .failure(error)
                    }
                    return (index, result)
                }
            }
            
            
            ///그룹에서 리턴되면 오는 곳
            for await (index, result) in group {
                switch result {
                case .success(let detail):
                    await MainActor.run {
                        _filterActivityDetailList[index] = detail
                    }
                case .failure(let error):
                    filterActivityindicats.remove(index)
                    
                    let error = error as? APIError
                    print("prefetch 실패 \(index): \(error?.userMessage ?? "알수 없는 오류")")
                }
            }
        }
        
        pendingFetchIndices.removeAll()
    }
    
    
    
}

// MARK: Helper
extension HomeViewModel {
    
    /// 이미지 로드 함수
    private func requestThumbnailImage(_ paths: [String]) async throws -> UIImage {
        
        guard !paths.isEmpty else {
            let fallback = UIImage(systemName: "star")!
            return fallback
        }
        /// 확장자에 따라 이미지 또는 동영상 썸넴일 이미지 보여줌
        return try await imageLoadUseCases.thumbnailImage.execute(path: paths[0], scale: scale)
        
    }
    
    /// 상세 정보 조회
    private func  reqeuestActivityDetailList<T: ActivityModelBuildable>(_ data:  ActivitySummaryEntity, type: T.Type) async throws -> T {
        
        let detail = try await activityUseCases.activityDetail.execute(id: data.activityID)
        
        let thumbnailImage = try await self.requestThumbnailImage(detail.thumbnails)
        
        
        return T(from: detail, thumbnail: thumbnailImage)
        
    }
}



// MARK:  Keep Status
extension HomeViewModel {
    private func handleKeepActivity(_ index: Int) {
        Task {
            await performKeepActivity(for: index)
        }
    }
    
    
    private func performKeepActivity(for index: Int) async {
        guard let data = _filterActivityDetailList[index] else {
            print("존재하지 않는 아이디 입니다.")
            return
        }
        
        /// 일단 네트워크 통신과 상관없이 상태 변경 (이후 실패시 기존 상태로 변경)
        /// 유저입장에서 통신전에 상태를 변경하는것을 먼저 인지하게 하고, 만약 실패시, UI를 다시 업데이트 하는 형태로 변경
        await toggleKeepUI(index) // UI 업데이트
        
        
        
        do {
            try await updateKeepStatus(for: data, at: index)
        } catch {
            await rollbackKeepUI(index, error: error)
        }
        
    }
    
    @MainActor
     private func toggleKeepUI(_ index: Int) {
         _filterActivityDetailList[index]?.isKeep.toggle()
     }
    
    
    private func updateKeepStatus(for data: FilterActivityModel, at index: Int) async throws {
        var statusChanged = data.isKeep
        statusChanged.toggle()
        
        let detail = try await activityUseCases.activityKeepCommand.execute(
            id: data.activityID,
            stauts: statusChanged
        )
        
        await MainActor.run {
            _filterActivityDetailList[index]?.isKeep = detail.keepStatus
        }
    }
    
    @MainActor
    private func rollbackKeepUI(_ index: Int, error: Error) {
        _filterActivityDetailList[index]?.isKeep.toggle()
        handleError(error)
    }

}


// MARK: Action
extension HomeViewModel {
    
    enum Action {
        case selectionChanged(flag: Flag, filter: Filter)
        case prefetchNewContent(index: Int)
        case prefetchfilterActivityContent(index: Int)
        case paginationAcitiviyList(index: Int)
        case keepButtonTapped(index: Int)
        case resetError
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case let .selectionChanged(flag, filter):
            guard flag != selectedFlag || filter != selectedFilter else { return }
            selectedFlag = flag
            selectedFilter = filter
            handleSelectionChanged(flag, filter)
        case .prefetchNewContent(let index):
            handlePrefetchNewContent(index)
        case .prefetchfilterActivityContent(let index):
            handleFilterDetailPrefetch(index)
        case let .paginationAcitiviyList(index):
            handleFilterPaginationRequest(index: index)
        case .keepButtonTapped(let index):
            handleKeepActivity(index)
        case .resetError:
            handleResetError()
            
        }
    }
    
    
}


// MARK: Alert 처리
extension HomeViewModel: AnyObjectWithCommonUI {
    
    var isShowingError: Bool { output.isShowingError }
    
    var presentedErrorTitle: String? { output.presentedError?.message.title }
    
    var presentedErrorMessage: String? { output.presentedError?.message.msg }
    
    var isLoading: Bool { output.isLoading }
    
    var presentedErrorCode: Int?  { output.presentedError?.code }
    
    func resetErrorAction() { action(.resetError) }
    
    
    
}

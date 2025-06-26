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
    
    private let activityListUseCase: DefaultActivityListUseCase
    private let activityNewLisUseCase: DefaultNewActivityListUseCase
    private let activityDeatilUseCase: DefaultActivityDetailUseCase
    private let activityKeepCommandUseCase: DefaultActivityKeepCommandUseCase
    private let imageLoader: DefaultLoadImageUseCase
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    private var scale: CGFloat = 0
    private let limit = 10
    private var nextCursor: String?
    private var paginationInProgress = false //페이지네이션 진행중 여부
    
    
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
            //dump(output.filterActivityDetailList)
        }
    }
    private var pendingFetchIndices = Set<Int>() // 스크롤 펜딩
    
    
    
    
    init(
        activityListUseCase: DefaultActivityListUseCase,
        activityNewLisUseCase: DefaultNewActivityListUseCase,
        activityDeatilUseCase: DefaultActivityDetailUseCase,
        activityKeepCommandUseCase: DefaultActivityKeepCommandUseCase,
        imageLoader: DefaultLoadImageUseCase
    ) {
        self.activityListUseCase = activityListUseCase
        self.activityNewLisUseCase = activityNewLisUseCase
        self.activityDeatilUseCase = activityDeatilUseCase
        self.activityKeepCommandUseCase = activityKeepCommandUseCase
        self.imageLoader = imageLoader
        
        transform()
    }
    
    
}

// MARK: Input/Output
extension HomeViewModel {
    
    struct Input {
        var selectedParams = PassthroughSubject<(Flag, Filter), Never>()
        
    }
    
    struct Output {
        
        var isLoading = true
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
        
        var activityNewDetailList: [NewActivityModel] = []
        var filterActivityDetailList: [FilterActivityModel] = []
    }
    
    func transform() {
        /// 필터가 눌렸을 때, 구독 또는 최초 실행시 구독
        /// 조건1) 기존 필터와 같은 내용인가? -> 통신 X
        /// 조건2) 기존 필터와 서로 내용이 다른가? -> 통신, 필터가 선택되는거 자체가 신규액티비티도 업데이트 해야하는 상황
        
        input.selectedParams.removeDuplicates  {
            $0 == $1
        }.sink { [weak self] (flag, filter) in
            
            self?.requestActivities(flag, filter)
            print("버튼이 눌렸습니다.")
            
        }.store(in: &cancellables)
        
    }
    
    /// onAppear시 호출 함수
    func requestActivities(_ flag: Flag, _ filter: Filter) {
        Task {
            await MainActor.run {
                output.isLoading = true
                newActivityindicats.removeAll() // Set indicats 초기화
                filterActivityindicats.removeAll() // Set indicats 초기화
                
            }
            await fetchNewList(flag.requestValue, filter.requestValue)
            await fetchFilterList(flag.requestValue, filter.requestValue)
            
            await MainActor.run {
                output.isLoading = false
                
            }
        }
    }
    
    
    /// 신규 액티비티 조회
    private func fetchNewList(_ country: String?, _ category: String?) async {
        
        do {
            
            let summary = try await activityNewLisUseCase.execute(country: country, category: category)
            let details = try await prefetchInitial(for: summary, type: NewActivityModel.self)
            newActivitySummaryList = summary
            
            await MainActor.run {
                /// 데이터 초기화
                _activityNewDetailList = [:]
                for (index, data)in details {
                    _activityNewDetailList[index] = data
                }
                
            }
        } catch let error as APIError {
            await MainActor.run {
                output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
            }
        } catch {
            print(error)
        }
    }
    
    /// 필터 데이터 조회
    private func fetchFilterList(_ country: String?, _ category: String?) async {
        
        let requestDto = ActivitySummaryListRequestDTO(country: country, category: category, limit: "\(limit)", next: nil)
        
        do {
            let summary = try await activityListUseCase.execute(requestDto: requestDto)
            let uniqueList = removeDuplicatesFromFilterList(filterList: summary.data)
            
            nextCursor = summary.nextCursor
       
            let details = try await prefetchInitial(for: uniqueList, type: FilterActivityModel.self)
            filterActivitySummaryList = summary.data
            
            await MainActor.run {
                /// 데이터 초기화
                _filterActivityDetailList = [:]
                for (index, data)in details {
                    _filterActivityDetailList[index] = data
                }
            }
        } catch let error as APIError {
            await MainActor.run {
                output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
            }
        } catch {
            print(#function, error)
        }
        
        
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
    
    /// New 있으면 필터에는 보이지 않게 하기 위한 중복제거 함수
    private func removeDuplicatesFromFilterList(filterList: [ActivitySummaryEntity]) -> [ActivitySummaryEntity] {
        
        /// Set으로 만들어 시간복잡도를 줄임 (Set : O(1), Array: O(n)
        let newIDs = Set(newActivitySummaryList.map { $0.activityID })
        
        let filteredList = filterList.filter {
            !newIDs.contains($0.activityID)
        }
        
        return filteredList
    }
    
    /// 상세 정보 조회
    private func  reqeuestActivityDetailList<T: ActivityModelBuildable>(_ data:  ActivitySummaryEntity, type: T.Type) async throws -> T {
        
        let detail = try await self.activityDeatilUseCase.execute(id: data.activityID)
        let thumbnailImage = try await self.requestThumbnailImage(detail.thumbnails)
        
         
        return T(from: detail, thumbnail: thumbnailImage)
        
    }
    
    /// 이미지 로드 함수
    private func requestThumbnailImage(_ paths: [String]) async throws -> UIImage {
        
        guard !paths.isEmpty else {
            let fallback = UIImage(systemName: "star")!
            return fallback
        }
        
        return try await imageLoader.execute(paths[0], scale: scale)
        
    }
//  상세뷰에서만 관리하자
//    private func getMediatype(from path: String) ->  MediaType   {
//        let fileExtension = URL(fileURLWithPath: path).pathExtension.lowercased()
//
//        if let utType = UTType(filenameExtension: fileExtension) {
//            if utType.conforms(to: .image) {
//                return .image
//            } else if utType.conforms(to: .movie) {
//                return .media
//            } else {
//                return .unknown
//            }
//        } else {
//            return .unknown
//        }
//    }
    
    
    private func handleResetError() {
        output.presentedError = nil
    }
    
    private func handleUpdateScale(_ scale: CGFloat) {
        self.scale = scale
    }
    
}

// MARK: New Activity 관련
extension HomeViewModel {
    
    private func triggerNewDetailPrefetch(_ index: Int) {
        Task {
            await fetchNewDetailIfNeeded(for: index)
        }
    }
    
    // 캐러셀이 이동하면 호출
    private func fetchNewDetailIfNeeded(for index: Int) async   {
        /// +2, 최초 로딩시, 3개의 [0, 1,  2]데이터를 가져옴, 이후 1번 인덱스에도착하면 3번 데이터를 호출
        let fetchIndex = index + 1
        
        /// 해결방안 Set 사용
        guard !newActivityindicats.contains(fetchIndex), fetchIndex < newActivitySummaryList.count else { return }
        newActivityindicats.insert(fetchIndex)
        
        do {
            let detail = try await reqeuestActivityDetailList(newActivitySummaryList[fetchIndex], type: NewActivityModel.self)
            await MainActor.run {
                _activityNewDetailList[fetchIndex] = detail
            }
        } catch let error as APIError {
            // 요청 실패 시 Set에서 제거
            newActivityindicats.remove(fetchIndex)
            print(#function, error.userMessage)
        } catch {
            newActivityindicats.remove(fetchIndex)
            print(#function, error)
        }
        
    }
    
       
    
    
}

// MARK: 필터 데이터 관련

extension HomeViewModel {
    
    private func triggerFilterDetailPrefetch(_ index: Int) {
        Task {
            await fetchFilterDetailIfNeeded(for: index)
        }
    }
    
    ///필터가 OnAppear 될 때마다 호출
    ///prefetch: 상세 데이터 미리 불러오기
    private func fetchFilterDetailIfNeeded(for index: Int) async   {
        /// +1, 최초 로딩시, 3개의 [0, 1,  2]데이터를 가져옴, 이후 2번 인덱스에도착하면 3번 데이터를 호출
        let fetchIndex = index + 1
         
        if fetchIndex >= filterActivitySummaryList.count {
            pendingFetchIndices.insert(fetchIndex)
            return
        }
        
        guard !paginationInProgress,!filterActivityindicats
            .contains(fetchIndex), fetchIndex < filterActivitySummaryList.count else { return }
        filterActivityindicats.insert(fetchIndex)
        
        do {
            let detail = try await reqeuestActivityDetailList(filterActivitySummaryList[fetchIndex], type: FilterActivityModel.self)
            await MainActor.run {
                _filterActivityDetailList[fetchIndex] = detail
            }
        } catch let error as APIError {
            // 요청 실패 시 Set에서 제거
            filterActivityindicats.remove(fetchIndex)
            print(#function, error.userMessage)
        } catch {
            filterActivityindicats.remove(fetchIndex)
            print(#function, error)
        }
        
    }
    
    private func triggerPaginationFilterPrefetch(_ country: String?, _ category: String?, index: Int) {
        Task {
            await paginationFilterActivityList(country, category, for: index)
        }
    }
    
    /// Pagination: 다음 페이지 요청
    private func paginationFilterActivityList(_ country: String?, _ category: String?, for index: Int) async {
        
        let threshold = 2
     
        guard !paginationInProgress,
                index >= filterActivitySummaryList.count - threshold,
                let nextCursor = self.nextCursor else { return }
        paginationInProgress = true
        
        defer {
              paginationInProgress = false
          }
        
        let requestDto = ActivitySummaryListRequestDTO(country: country, category: category, limit: "\(limit)", next: nextCursor)
        
        do {
            let summary = try await activityListUseCase.execute(requestDto: requestDto)
            let uniqueList = removeDuplicatesFromFilterList(filterList: summary.data)
            filterActivitySummaryList.append(contentsOf: uniqueList)
            self.nextCursor = summary.nextCursor

            await processPendingPrefetches() /// 데이터를 불러오는동안 스크롤 이벤트에 대한 펜딩 처리
            
            
        } catch let error as APIError {
            await MainActor.run {
                output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
            }
        } catch {   
            print(#function, error)
        }
    }
    
    // MARK: TODO: 에러처리 시퀀스 추가 해야함 withTaskGroup은 에러처리가 불가능

    /// 펜딩에 많이 있을 수 있으니 withTaskGroup으로 동시에 데이터 처리
    private func processPendingPrefetches() async {
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

// MARK:  Keep Status

extension HomeViewModel {
    private func triggerKeepActivity(_ index: Int) {
        Task {
            await requestAcitivityKeep(for: index)
        }
    }
    
    /// 여기 메인액터로 묶는게 더 좋을까?
    private func requestAcitivityKeep(for index: Int) async   {
      
        let data = _filterActivityDetailList[index]
        
        guard let data else {
            print("존재하지 않는 아이디 입니다.")
            return
        }
        
        /// 일단 네트워크 통신과 상관없이 상태 변경 (이후 실패시 기존 상태로 변경)
        /// 유저입장에서 통신전에 상태를 변경하는것을 먼저 인지하게 하고, 만약 실패시, UI를 다시 업데이트 하는 형태로 변경
        await MainActor.run {
            _filterActivityDetailList[index]?.isKeep.toggle()
        }
  
        do {
            var statusChanged =  data.isKeep
            statusChanged.toggle()

            let detail = try await activityKeepCommandUseCase.execute(id: data.activityID, stauts: statusChanged)
            await MainActor.run {
                _filterActivityDetailList[index]?.isKeep = detail.keepStatus
            }
        } catch let error as APIError {
            await MainActor.run {
                _filterActivityDetailList[index]?.isKeep.toggle()
            }
            print(#function, error.userMessage)
        } catch {
            /// 실패시 원래대로 상태 변경
            await MainActor.run {
                _filterActivityDetailList[index]?.isKeep.toggle()
            }
        }
        
    }
}


// MARK: Action
extension HomeViewModel {
    
    enum Action {
        case onAppearRequested(flag: Flag, filter: Filter)
        case updateScale(scale: CGFloat)
        case selectionChanged(flag: Flag, filter: Filter)
        case prefetchNewContent(index: Int)
        case prefetchfilterActivityContent(index: Int)
        case paginationAcitiviyList(flag: Flag, filter: Filter, index: Int)
        case keepButtonTapped(index: Int)
        case resetError
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case let .onAppearRequested(flag, filter),
            let .selectionChanged(flag, filter):
            input.selectedParams.send((flag, filter))
        case .updateScale(let scale):
            handleUpdateScale(scale)
        case .prefetchNewContent(let index):
            triggerNewDetailPrefetch(index)
        case .prefetchfilterActivityContent(let index):
            triggerFilterDetailPrefetch(index)
        case let .paginationAcitiviyList(flag, filter, index):
            triggerPaginationFilterPrefetch(flag.requestValue, filter.requestValue, index: index)
        case .keepButtonTapped(let index):
            triggerKeepActivity(index)
        case .resetError:
            handleResetError()
        
        }
    }
    
    
}


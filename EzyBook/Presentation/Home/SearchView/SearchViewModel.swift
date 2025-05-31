//
//  SearchViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 5/31/25.
//

import SwiftUI
import Combine

final class SearchViewModel: ViewModelType {
    
    private let activitySearchLisUseCase: DefaultActivitySearchUseCase
    private let activityDeatilUseCase: DefaultActivityDetailUseCase
    private let activityKeepCommandUseCase: DefaultActivityKeepCommandUseCase
    private let imageLoader: DefaultLoadImageUseCase
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    private var scale: CGFloat = 0
    
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
            print(output.activitySearchDetailList)
        }
    }
    
 
    
    init(
        activitySearchLisUseCase: DefaultActivitySearchUseCase,
        activityDeatilUseCase: DefaultActivityDetailUseCase,
        activityKeepCommandUseCase: DefaultActivityKeepCommandUseCase,
        imageLoader: DefaultLoadImageUseCase
    ) {

        self.activitySearchLisUseCase = activitySearchLisUseCase
        self.activityDeatilUseCase = activityDeatilUseCase
        self.activityKeepCommandUseCase = activityKeepCommandUseCase
        self.imageLoader = imageLoader
        
        transform()
    }
    
    
}

// MARK: Input/Output
extension SearchViewModel {
    
    struct Input {
        var query = ""
        var searchButtonTapped = PassthroughSubject<String, Never>()
        
    }
    
    struct Output {
        
        var isLoading = true
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
        
        var activitySearchDetailList: [FilterActivityModel] = []
    }
    
    func transform() {

        input.searchButtonTapped.removeDuplicates()
        .sink { [weak self] query in
            self?.requestSearchList(query: query)
            }
            .store(in: &cancellables)
            
    }
    
    
    func requestSearchList(query: String) {
        Task {
            await MainActor.run {
                output.isLoading = true
                searchActivityindicats.removeAll() // Set indicats 초기화
            }
            
            await fetchSearchList(query)
    
            
            await MainActor.run {
                output.isLoading = false
                
            }
        }
    }
    
    
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
        
        let detail = try await self.activityDeatilUseCase.execute(id: data.activityID)
        let thumbnailImage = try await self.requestThumbnailImage(detail.thumbnails)
        
        return T(from: detail, thumbnail: thumbnailImage)
        
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

// MARK: 추천 관련
extension SearchViewModel {
    
    //TODO: 추후 구현
    
}

// MARK: 광고 관련
extension SearchViewModel {
    
    //TODO: 추후 구현
    
}

// MARK: 검색 데이터 관련
extension SearchViewModel {
    
    private func handleRequestQuery() {
        
        if input.query.isEmpty {
            output.presentedError = DisplayError.error(code: -1, msg: "공백 제외\n1글자 이상 입렵해주세요")
            return
        }
        
        let _query = input.query.trimmingCharacters(in: .whitespaces)
        input.searchButtonTapped.send(_query)
        
    }
    
    ///검색리 로드되는 함수
    private func fetchSearchList(_ query: String) async {
        
        do {
            let summary = try await activitySearchLisUseCase.execute(title: query)
            let details = try await prefetchInitial(for: summary, type: FilterActivityModel.self)
            searchActivitySummaryList = summary
            
            await MainActor.run {
                /// 데이터 초기화
                _searchActivityDetailList = [:]
                for (index, data)in details {
                    _searchActivityDetailList[index] = data
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
    
   
    private func triggerSearchListPrefetch(_ index: Int) {
        Task {
            await fetchSearchListNeeded(for: index)
        }
    }
    
    /// Prefetch
    private func fetchSearchListNeeded(for index: Int) async   {
        /// +2, 최초 로딩시, 3개의 [0, 1,  2]데이터를 가져옴, 이후 1번 인덱스에도착하면 3번 데이터를 호출
        let fetchIndex = index + 1
        
        /// 해결방안 Set 사용
        guard !searchActivityindicats.contains(fetchIndex), fetchIndex < searchActivitySummaryList.count else { return }
        searchActivityindicats.insert(fetchIndex)
        
        do {
            let detail = try await reqeuestActivityDetailList(searchActivitySummaryList[fetchIndex], type: FilterActivityModel.self)
            await MainActor.run {
                _searchActivityDetailList[fetchIndex] = detail
            }
        } catch let error as APIError {
            // 요청 실패 시 Set에서 제거
            searchActivityindicats.remove(fetchIndex)
            print(#function, error.userMessage)
        } catch {
            searchActivityindicats.remove(fetchIndex)
            print(#function, error)
        }
    
    }
    
}

// MARK:  Keep Status
extension SearchViewModel {
    private func triggerKeepActivity(_ index: Int) {
        Task {
            await requestAcitivityKeep(for: index)
        }
    }
    
    /// 여기 메인액터로 묶는게 더 좋을까?
    private func requestAcitivityKeep(for index: Int) async   {
      
        let data = _searchActivityDetailList[index]
        
        guard let data else {
            print("존재하지 않는 아이디 입니다.")
            return
        }
        
        /// 일단 네트워크 통신과 상관없이 상태 변경 (이후 실패시 기존 상태로 변경)
        /// 유저입장에서 통신전에 상태를 변경하는것을 먼저 인지하게 하고, 만약 실패시, UI를 다시 업데이트 하는 형태로 변경
        await MainActor.run {
            _searchActivityDetailList[index]?.isKeep.toggle()
        }
  
        do {
            var statusChanged =  data.isKeep
            statusChanged.toggle()
            print(statusChanged)
            let detail = try await activityKeepCommandUseCase.execute(id: data.activityID, stauts: statusChanged)
            await MainActor.run {
                _searchActivityDetailList[index]?.isKeep = detail.keepStatus
            }
        } catch let error as APIError {
            await MainActor.run {
                _searchActivityDetailList[index]?.isKeep.toggle()
            }
            print(#function, error.userMessage)
        } catch {
            /// 실패시 원래대로 상태 변경
            await MainActor.run {
                _searchActivityDetailList[index]?.isKeep.toggle()
            }
        }
        
    }
}


//// MARK: Action
extension SearchViewModel {
    
    enum Action {
        case updateScale(scale: CGFloat)
        case searchButtonTapped
        case prefetchSearchContent(index: Int)
        case keepButtonTapped(index: Int)
        case resetError
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .updateScale(let scale):
            handleUpdateScale(scale)
        case .searchButtonTapped:
            handleRequestQuery()
        case .prefetchSearchContent(let index):
            triggerSearchListPrefetch(index)
        case .keepButtonTapped(index: let index):
            triggerKeepActivity(index)
        case .resetError:
            handleResetError()
            
      
        }
    }
    
    
}

//
//  CommunityViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 8/2/25.
//

import SwiftUI
import Combine
import CoreLocation

final class CommunityViewModel: ViewModelType {
    
    
    private let communityUseCases: CommunityUseCases
    private let loactionService: LocationServiceProtocol
    
    var input = Input()
    @Published var output = Output()
    
    var cancellables = Set<AnyCancellable>()
    
    @Published var selectedFlag: Flag = .all
    @Published var selectedFilter: Filter = .all
    @Published var distance: CGFloat = 0.5
    @Published var postSort: PostSort = .createdAt
    
    private let limit = 10
    private var nextCursor: String?
    private var location = UserSession.shared.userLocation
    private let distanceSubject = PassthroughSubject<CGFloat, Never>()
    
    private var serverDistance: Int {
        Int(distance * 50000)
    }
    
    init(
        communityUseCases: CommunityUseCases,
        loactionService: LocationServiceProtocol
    ){
        
        self.communityUseCases = communityUseCases
        self.loactionService = loactionService
        
        Task {
            await fetchLocationIfNeeded()
        }
        
        loadInitialPost()
        transform()
    }
    
}

// MARK: Input/Output
extension CommunityViewModel {
    
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
        
        var postList: [PostSummaryEntity] = []
        
    }
    
    func transform() {
        
        $distance
            .dropFirst()
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                Task {
                    await self.reloadPostList(flag: self.selectedFlag, filter: self.selectedFilter)
                }
            }
            .store(in: &cancellables)
        
        
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
    
    
}

// MARK: 초기 호출
extension CommunityViewModel {
    
    private func loadInitialPost() {
        Task {
            await MainActor.run { output.isLoading = true }
            await performPostList(selectedFlag, selectedFilter)
            await MainActor.run { output.isLoading = false }
        }
    }
    
    
    
    
    private func performPostList(_ flag: Flag, _ filter: Filter) async {
        do {
            let query = await makePostLookUpQuery(flag, filter)
            let data = try await communityUseCases.postSummary.execute(query: query)
            nextCursor = data.nextCursor
            
            await MainActor.run {
                output.postList.append(contentsOf: data.data)
            }
            
        } catch {
            await handleError(error)
        }
    }
    
    private func makePostLookUpQuery(_ flag: Flag, _ filter: Filter) async -> ActivityPostLookUpQuery {
        return ActivityPostLookUpQuery(
            country: flag.requestValue,
            category: filter.requestValue,
            longitude: location.map { String(format: "%.6f", $0.longitude) },
            latitude: location.map { String(format: "%.6f", $0.latitude) },
            maxDistance: String(serverDistance),
            limit: limit,
            next: nextCursor,
            orderBy: postSort.orderBy
        )
    }

    @MainActor
    func fetchLocationIfNeeded() async {
        
        guard location == nil  else { return }

        do {
            let coordinate = try await loactionService.fetchCurrentLocation()
            
            let savedLocation = UserLocation(longitude: coordinate.longitude, latitude: coordinate.latitude)
            UserSession.shared.updateLocation(savedLocation)
            
            print(savedLocation)
            location = savedLocation
            

            
        } catch {
            print("📍 위치 가져오기 실패:", error.localizedDescription)
        }
    }
    
}

extension CommunityViewModel {
    /// 필터 버튼 선택
    private func handleSelectionChanged(_ flag: Flag, _ filter: Filter) {
        Task {
            await reloadPostList(flag: flag, filter: filter)
        }
    }
    
    private func reloadPostList(flag: Flag, filter: Filter) async {
        nextCursor = nil
        await MainActor.run {
            output.postList = []
            output.isLoading = true
        }

        await performPostList(flag, filter)

        await MainActor.run {
            output.isLoading = false
        }
    }
    
    // MARK: 페이지네이션
    private func handleFilterPaginationRequest(index: Int) {
        
        if nextCursor == "0" || output.postList.count - index > 3  {
            return
        }
        
        Task {
            let currentFlag = selectedFlag
            let currentFilter = selectedFilter
          
            await performPostList(currentFlag, currentFilter)
        }
    }
    
    
    // MARK: 정렬 버튼 선택
    private func handleSortButtonTapped() {
        postSort = postSort == .createdAt ? .likes : .createdAt
        
        Task {
            let currentFlag = selectedFlag
            let currentFilter = selectedFilter
              
            await performPostList(currentFlag, currentFilter)
        }
    }

 
}

// MARK: 검색

extension CommunityViewModel {
    
    // MARK: 검색
    private func handleSearchRequest(_ query: String) {
        Task {
            nextCursor = nil
            await MainActor.run {
                output.postList = []
                output.isLoading = true
            }
            
            await performSearchPost(query)
           
            
            await MainActor.run {
                output.isLoading = false
            }
        }
    }
    
    private func performSearchPost(_ query: String) async {
        do {
            
            let data = try await communityUseCases.postSearch.execute(title: query)
            
            await MainActor.run {
                output.postList = data
            }
            
            
        } catch {
            await handleError(error)
        }
    }
}

//// MARK: Action
extension CommunityViewModel {
    
    enum Action {
        case selectionChanged(flag: Flag, filter: Filter)
        case paginationPostList(index: Int)
        case sortButtonTapped
        case searchButtonTapped
        
        
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case let .selectionChanged(flag, filter):
            guard flag != selectedFlag || filter != selectedFilter else { return }
            selectedFlag = flag
            selectedFilter = filter
            handleSelectionChanged(flag, filter)
        case .paginationPostList(let index):
            handleFilterPaginationRequest(index: index)
        case .sortButtonTapped:
            handleSortButtonTapped()
        case .searchButtonTapped:
            
            if input.query.isEmpty {
                output.presentedMessage = DisplayMessage.error(code: -1, msg: "공백 제외\n1글자 이상 입렵해주세요")
                return
            }
            let _query = input.query.trimmingCharacters(in: .whitespaces)
            input.searchButtonTapped.send(_query)
        }
    }
    
    
}

// MARK: Alert 처리
extension CommunityViewModel: AnyObjectWithCommonUI {
    
    var isShowingError: Bool { output.isShowingMessage }
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
    
    
}

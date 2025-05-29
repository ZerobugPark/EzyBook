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
    
    
    /// Result Storage  Property
    /// 통신을 할 인덱스 관리 및 저장되는 데이터
    
    private var newActivitySummaryResult: [ActivitySummaryEntity] = []
    private var newActivityindicats = Set<Int>()
    
    
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
        var selectedParams = PassthroughSubject<(Flag, Filter), Never>()
        
    }
    
    struct Output {
        
        var isLoading = true
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
        
        var activityNewDetailList: [NewActivityModel] = []
        var filterActivityDetailList: [FilterActivityModel] = [
//            FilterActivityModel(
//                from: ActivityDetailEntity(
//                    dto: ActivityDetailResponseDTO(
//                        activityID: "123",
//                        title: "대한민국에서 신나는 먹방",
//                        country: "대한민국",
//                        category: "먹방",
//                        thumbnails: [],
//                        geolocation: ActivityGeolocationDTO(longitude: 1.0, latitude: 1.0),
//                        startDate: "",
//                        endDate: "2025-08-07",
//                        price: ActivityPriceDTO(original: 324000, final: 123000),
//                        tags: ["New 오픈특가"],
//                        pointReward: 10,
//                        restrictions: ActivityRestrictionsDTO(minHeight: 10, minAge: 10, maxParticipants: 10),
//                        description: "세계적으로 유명한 대한민국에서 오감을 만족시키는 여정에서 잊지 못할 추억을 체험해보세요. 새로운 시각을 가질 시간이 될 것입니다. 전문 가이드가 함께합니다!",
//                        isAdvertisement: true,
//                        isKeep: true,
//                        keepCount: 100,
//                        totalOrderCount: 100,
//                        schedule: [],
//                        reservationList: [],
//                        creator: ActivityCreatorDTO(userID: "123", nick: "123", introduction: "123"),
//                        createdAt: nil,
//                        updatedAt: nil
//                    )
//                ),
//                thumbnail: UIImage(systemName: "star")!
//            )
            
        ]
        
    }
    
    func transform() {
        
        
        /// 필터가 눌렸을 때, 구독 또는 최초 실행시 구독
        /// 조건1) 기존 필터와 같은 내용인가? -> 통신 X
        /// 조건2) 기존 필터와 서로 내용이 다른가? -> 통신, 필터가 선택되는거 자체가 신규액티비티도 업데이트 해야하는 상황
        
        input.selectedParams.removeDuplicates  {
            $0 == $1
        }.sink { [weak self] (flag, filter) in
            
            self?.requestActivities(flag, filter)

            
        }.store(in: &cancellables)
        
        
        
    }
    
    /// 단순 액티비티를 불러오는 함수
    private func requestNewActivities(_ flag: Flag, _ filter: Filter)
    {
        let country = flag.requestValue
        let category =  filter.requestValue
        
        Task {
            do {
                let result = try await activityNewLisUseCase.execute(country: country, category: category)
                
                
            }  catch let error as APIError {
                await MainActor.run {
                    output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
                }
            }
        }
        
    }
    
    private func 
    
    
    
    /// 일회성 단순 최초 호출 용도로 설계를 바꾸자
    /// 즉 1회성으로 통신할 수있는 범용 함수
    private func requestActivities(_ flag: Flag = .all, _ filter: Filter = .all) {
        
        let country = flag.requestValue
        let category =  filter.requestValue
        
        let requestDto = ActivitySummaryListRequestDTO(country: country, category: category, limit: "\(limit)", next: nextCursor)
        
        Task {
            do {
                /// async let:    비동기 작업 시작
                async let filterListResult = activityListUseCase.execute(requestDto: requestDto)
                async let newListResult = activityNewLisUseCase.execute(country: country, category: category)
                
                // 둘 다 성공해야 넘어감
                let (filterList, newList) = try await (filterListResult, newListResult)
                
                let newActivitydetails = try await reqeuestActivityDetailList(newList, type: NewActivityModel.self)
                
                let filterListdetails = try await reqeuestActivityDetailList(filterList.data, type: FilterActivityModel.self)
                
                /// 커서 저장
                nextCursor = filterList.nextCursor
                
                
                await MainActor.run {
                    output.activityNewDetailList = newActivitydetails
                    output.filterActivityDetailList = filterListdetails
                    output.isLoading = false
                }
            } catch let error as APIError {
                await MainActor.run {
                    output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
                }
            }
        }
    }
    
    
    
    private func  reqeuestActivityDetailList<T: ActivityModelBuildable>(_ data:  [ActivitySummaryEntity], type: T.Type) async throws -> [T] {
        
        return try await withThrowingTaskGroup(of: T.self) { [weak self] group in
            guard let self = self else {
                throw APIError(localErrorType: .decodingError)
            }
                for item in data {
                    group.addTask {
                        let detail = try await self.activityDeatilUseCase.execute(id: item.activityID)
                        let thumbnailImage = try await self.requestThumbnailImage(detail.thumbnails)
                        /// 아래 for문으로 이동
                        return T(from: detail, thumbnail: thumbnailImage)
                    }
                }

                var result: [T] = []
                for try await item in group {
                    result.append(item)
                }

                return result
            }
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

// MARK: Action
extension HomeViewModel {
    
    enum Action {
        case onAppearRequested
        case updateScale(scale: CGFloat)
        case selectionChanged(flag: Flag, filter: Filter)
        case resetError
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case let .selectionChanged(flag, filter):
            
            //requestActivities(flag, filter)
        case .updateScale(let scale):
            handleUpdateScale(scale)
        case .onAppearRequested:
            requestActivities()
        case .resetError:
            handleResetError()
        }
    }
    
    
}

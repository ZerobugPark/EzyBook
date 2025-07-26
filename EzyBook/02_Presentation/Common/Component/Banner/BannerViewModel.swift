//
//  BannerViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 7/20/25.
//

import SwiftUI
import Combine

final class BannerViewModel: ViewModelType {

    var input = Input()
    @Published var output = Output()

    
    var cancellables = Set<AnyCancellable>()
    
    private var scale: CGFloat
    
    private let imageLoadUseCases: ImageLoadUseCases
    private let bannerUseCase: BannerInfoUseCase
  
    
    init(
        imageLoadUseCases: ImageLoadUseCases,
        bannerUseCase: BannerInfoUseCase,
        scale: CGFloat
    ) {

        self.imageLoadUseCases = imageLoadUseCases
        self.bannerUseCase = bannerUseCase
        self.scale = scale
        
        transform()
        loadInitialBannerList()
    }
    
    
 
}

// MARK: Input/Output
extension BannerViewModel {
    
    struct Input {
    }
    
    struct Output {
        
        var isLoading = false
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
        
        var bannerList: [BannerEntity] = []

    }
    

    func transform() {  }
    
    
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

// MARK: 배너 관련
extension BannerViewModel {
    
    private func loadInitialBannerList() {
        Task {
            await loadBannerList()
        }
    }
    
    private func loadBannerList() async {
        do {
            let data = try await bannerUseCase.execute()
            let resultData = await attachImagesToBanners(from: data)
            await updateBannerListUI(resultData)
        } catch {
            await handleError(error)
        }
    }
    
    
    @MainActor
    private func updateBannerListUI(_ banners: [BannerEntity]) {
        output.bannerList = banners
    }
    
    
    private func attachImagesToBanners(from entities: [BannerEntity]) async -> [BannerEntity] {
         
        let images = await loadImages(from: entities, scale: scale)
        var resultData = entities
        
        for (index, image) in images.enumerated() {
            resultData[index].bannerImage = image
        }
            
        return resultData
    }

    
    private func loadImages(from entities: [BannerEntity], scale: CGFloat) async -> [UIImage] {
        await withTaskGroup(of: (Int, UIImage).self) { group in
            for (index, entity) in entities.enumerated() {
                group.addTask {
                    do {
                        let image = try await self .imageLoadUseCases.thumbnailImage.execute(path: entity.imageURL, scale: scale)
                            
                        return (index, image)
                    } catch {
                        return (index, UIImage(resource: .iconStarFill))
                    }
                }
            }

            var results: [(Int, UIImage)] = []
            for await result in group {
                results.append(result)
            }

            return results
                .sorted { $0.0 < $1.0 }
                .map { $0.1 }
        }
    }
    

}


extension BannerViewModel {
    
    enum Action {
        case resetError
    }
    
    func action(_ action: Action) {
        switch action {
        case .resetError:
                handleResetError()
        }
    }
}


// MARK: Alert 처리
extension BannerViewModel: AnyObjectWithCommonUI {
    
    var isShowingError: Bool { output.isShowingError }
    
    var presentedErrorTitle: String? { output.presentedError?.message.title }
    
    var presentedErrorMessage: String? { output.presentedError?.message.msg }
    
    var isLoading: Bool { output.isLoading }
    
    var presentedErrorCode: Int?  { output.presentedError?.code }
    
    func resetErrorAction() { action(.resetError) }
    
}

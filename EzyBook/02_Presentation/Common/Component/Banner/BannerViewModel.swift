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
    
    private var scale: CGFloat = 0
    
    private let imageLoadUseCases: ImageLoadUseCases
    private let bannerUseCase: BannerInfoUseCase
  
    
    init(
        imageLoadUseCases: ImageLoadUseCases,
        bannerUseCase: BannerInfoUseCase
    ) {

        self.imageLoadUseCases = imageLoadUseCases
        self.bannerUseCase = bannerUseCase
        
        transform()
    }
    
    
 
}

// MARK: Input/Output
extension BannerViewModel {
    
    struct Input {
    }
    
    struct Output {
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
        
        var bannerList: [BannerEntity] = []

    }
    
    
 
    
    func transform() {
    }
    
    private func handleUpdateScale(_ scale: CGFloat) {
        self.scale = scale
    }
    
    
}

// MARK: 배너 관련

extension BannerViewModel {
    

    private func handleRequestBanner() {
            
        Task {
            await loadBannerList()
        }
        
    }
    
    private func loadBannerList() async {
        do {
            let data = try await bannerUseCase.execute()
            let resultData = await loadBanners(from: data)
            
            await MainActor.run {
                output.bannerList = resultData
            }
            
        } catch let error as APIError {
            await MainActor.run {
                output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
            }
        } catch {
            print(#function,  "알 수 없는 오류")
        }
        
    }
    
    
    
    func loadBanners(from entities: [BannerEntity]) async -> [BannerEntity] {
        
        
        let images = await loadImages(from: entities, scale: scale)
        var resultData = entities
        
        for (index, image) in images.enumerated() {
            resultData[index].bannerImage = image
        }
            
        return resultData
    }

    
    func loadImages(from entities: [BannerEntity], scale: CGFloat) async -> [UIImage] {
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



// MARK: Action
extension BannerViewModel {
    
    enum Action {
        case onAppearRequested
        case updateScale(scale: CGFloat)
        
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .onAppearRequested:
            handleRequestBanner()
        case .updateScale(let scale):
            handleUpdateScale(scale)

        }
    }
    
    
}


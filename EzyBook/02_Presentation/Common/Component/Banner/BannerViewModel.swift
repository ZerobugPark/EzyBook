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
    
    private let bannerUseCase: BannerInfoUseCase
  
    
    init(bannerUseCase: BannerInfoUseCase) {
        self.bannerUseCase = bannerUseCase

        transform()
        loadInitialBannerList()
    }
    
    
 
}

// MARK: Input/Output
extension BannerViewModel {
    
    struct Input {
    }
    
    struct Output {
        
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        
        var bannerList: [BannerEntity] = []
        
    }
    

    func transform() {  }
    
    
    @MainActor
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            output.presentedMessage = DisplayMessage.error(code: apiError.code, msg: apiError.userMessage)
        } else {
            output.presentedMessage = DisplayMessage.error(code: -1, msg: error.localizedDescription)
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
            
            await updateBannerListUI(data)
            
        } catch {
            await handleError(error)
        }
    }
    
    
    @MainActor
    private func updateBannerListUI(_ banners: [BannerEntity]) {
        output.bannerList = banners
    }

    

}


// MARK: Alert 처리
extension BannerViewModel: AnyObjectWithCommonUI {
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
}

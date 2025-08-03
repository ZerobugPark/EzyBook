//
//  PostViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 8/3/25.
//

import SwiftUI
import Combine


final class PostViewModel: ViewModelType {
    
    
    private let writeActivityUseCase: WriteActivityUseCase
    
    var input = Input()
    @Published var output = Output()
    
    @Published var isConfirm: Bool = false
    
    /// input으로 넣으면 깔끔하긴 한데, 복잡해지고,, 빼면 편한데, 가독성이 떨어지구..
    @Published var title: String = "" {
        didSet {
            checkConfirmStatus()
        }
    }
    
    @Published var content: String = "" {
        didSet {
            checkConfirmStatus()
        }
    }
    
    var cancellables = Set<AnyCancellable>()
    private var selectedActivity: OrderList?
  
  
    init(
        writeActivityUseCase: WriteActivityUseCase
    ) {
        self.writeActivityUseCase = writeActivityUseCase
        transform()
        
    }
    
}

extension PostViewModel {
    
    struct Input { }
    
    struct Output {
        var isLoading = false
        
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        
        var country = ""
        var catrgory = ""
        var activityTitle = "투어를 선택해주세요"
        
     
    }
    
    func transform() { }
    
    
    
    
    @MainActor
    private func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            output.presentedMessage = DisplayMessage.error(code: apiError.code, msg: apiError.userMessage)
        } else {
            output.presentedMessage = DisplayMessage.error(code: -1, msg: error.localizedDescription)
        }
    }
    
    @MainActor
    private func handleSuccess() {
        output.presentedMessage = .success(msg: "액티비티 결제 내역이 없습니다.")
    }
    
}


// MARK: Activity Post
private extension PostViewModel {
    
    private func handlePost(_ images: [UIImage], _ videos: [URL]) {
        let imageTotalSize = images
            .compactMap { $0.jpegData(compressionQuality: 0.8) }
            .reduce(0) { $0 + $1.count }

        // 비디오 총 용량 계산
        let videoTotalSize = videos
            .compactMap { try? Data(contentsOf: $0) }
            .reduce(0) { $0 + $1.count }

        let totalSizeInMB = Double(imageTotalSize + videoTotalSize) / (1024 * 1024)

        print(imageTotalSize, videoTotalSize)

        
    }
}

// MARK: Check Status
private extension PostViewModel {
    
    private func checkConfirmStatus() {
        guard selectedActivity != nil else {
            isConfirm = false
            return
        }
        
        guard !title.isEmpty, !content.isEmpty else {
            isConfirm = false
            return
        }
        isConfirm = true
    }
    
}


// MARK: Activity Update
extension PostViewModel {
    
    private func handleActivityUpadte(_ activity: OrderList) {
        
        Task { @MainActor in
            output.activityTitle = activity.title
            output.country = activity.country
            output.catrgory = activity.category
            selectedActivity = activity
        }
        
    }
    
}


//// MARK: Action
extension PostViewModel {
    
    enum Action {
        case acitivitySelected(activity: OrderList)
        case writePost(images: [UIImage], videos: [URL])
        
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .acitivitySelected(let activity):
            handleActivityUpadte(activity)
        case let .writePost(images, videos):
            handlePost(images, videos)
            
        }
    }
    
    
}


// MARK: Alert 처리
extension PostViewModel: AnyObjectWithCommonUI {
    
    var isShowingError: Bool { output.isShowingMessage }
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    var isSuccessMessage: Bool { output.presentedMessage?.isSuccess ?? false }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }

}



//
//  PostViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 8/3/25.
//

import SwiftUI
import Combine


final class PostViewModel: ViewModelType {
    
    
    private let writeActivityRealmUseCase: WriteActivityRealmUseCase
    private let uploadUseCase: PostImageUploadUseCase
    private let writePostUseCase: PostActivityUseCase
    
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
    private var selectedActivity: OrderList? {
        didSet {
            checkConfirmStatus()
        }
    }
  
  
    init(
        writeActivityRealmUseCase: WriteActivityRealmUseCase,
        uploadUseCase: PostImageUploadUseCase,
        writePostUseCase :PostActivityUseCase
    ) {
        self.writeActivityRealmUseCase = writeActivityRealmUseCase
        self.uploadUseCase = uploadUseCase
        self.writePostUseCase = writePostUseCase
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
        output.presentedMessage = .success(msg: "게시글 작성이 완료되었습니다.")
    }
    
}


// MARK: Activity Post
private extension PostViewModel {
    
    private func handleWritePostRequest(_ images: [UIImage], _ videos: [URL]) {
        Task {
            
            await MainActor.run { output.isLoading = true }
            let videoPath = await performUploadVideoIfNeeded(videos)
            let imagePath = await performUploadImageIfNeeded(images)

            let allPaths: [String] = (videoPath?.files ?? []) + (imagePath?.files ?? [])

            let success = await performWritePost(title: title, content: content, paths: allPaths)

            await MainActor.run { output.isLoading = false }
            
            if success {
                await MainActor.run {
                    // 렘에 작성된 영역 저장 (향후 삭제시 렘에서도 제거 필요)
                    writeActivityRealmUseCase.execute(activityID: selectedActivity!.activityID)
                    handleSuccess()
                }
            }
        }
    }
    
    
    private func performWritePost(title: String, content: String, paths: [String]) async -> Bool {
        do {
            guard let selectedActivity else { return false }
            guard let location = UserSession.shared.userLocation else { return false }

            let data = try await writePostUseCase.execute(
                country: selectedActivity.country,
                category: selectedActivity.category,
                title: title,
                content: content,
                activity_id: selectedActivity.activityID,
                latitude: location.latitude,
                longitude: location.longitude,
                files: paths
            )

            dump(data)
            return true

        } catch {
            await handleError(error)
            return false
        }
    }
    
    
    
    
    // MARK: 파일 업로드
    private func performUploadVideoIfNeeded(_ videos: [URL]) async -> FileResponseEntity? {
        guard !videos.isEmpty else { return nil } // 아예 비어있으면 생략
        
        let videoData = convertURLToData(videos)
        guard !videoData.isEmpty else { return nil } // 변환 실패 등으로 비어있으면 생략
        
        do {
            let data = try await uploadUseCase.execute(videos: videoData)
            return data
        } catch {
            
            await handleError(error)
            return nil
        }
    }
    
    /// 비디오로 변환
    private func convertURLToData(_ videos: [URL]) -> [Data] {
        return videos.compactMap { try? Data(contentsOf: $0) }
        
    }
    
    
    private func performUploadImageIfNeeded(_ images: [UIImage]) async -> FileResponseEntity? {
        
        guard !images.isEmpty else { return nil }
    
        do {
            let data = try await uploadUseCase.execute(images: images)
            return data
        } catch {
            await handleError(error)
            return nil
        }
        
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
            handleWritePostRequest(images, videos)
            
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



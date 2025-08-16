//
//  PostViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 8/3/25.
//

import SwiftUI
import Combine

enum PostStatus: Hashable, Equatable {
    case create
    case modify(existing: PostSummaryEntity)
    
    var title: String {
        switch self {
        case .create:
            return "게시글 작성"
        case .modify:
            return "게시글 수정"
        }
    }
    
    var btnTitle: String {
        switch self {
        case .create:
            return "작성하기"
        case .modify:
            return "수정하기"
        }
    }
}

struct ModifyPost {
    let postID: String
    let title: String
    let content: String
    let files: [String]?
    
    
}


final class PostViewModel: ViewModelType {
    
    
    private let uploadUseCase: PostImageUploadUseCase
    private let writePostUseCase: PostActivityUseCase
    private let modifyPostUseCsae: PostModifyUseCase
    let postMode: PostStatus
    private var postID = ""
    private(set) var isModified: ModifyPost?
    
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
    @Published var selectedMedia: [PickerSelectedMedia] = []
  
    init(
        uploadUseCase: PostImageUploadUseCase,
        writePostUseCase: PostActivityUseCase,
        postStatus: PostStatus,
        modifyPostUseCsae: PostModifyUseCase
    ) {
        self.uploadUseCase = uploadUseCase
        self.writePostUseCase = writePostUseCase
        self.postMode = postStatus
        self.modifyPostUseCsae = modifyPostUseCsae
        
        
        // Prefill fields when editing an existing post
        if case let .modify(existing) = postMode {
            self.title = existing.title
            self.content = existing.content
            self.output.country = existing.activity?.country ?? ""
            self.output.category = existing.activity?.category ?? ""
            self.output.activityTitle = existing.activity?.title ?? "기존에 등록한 투어가 없습니다."
            self.postID = existing.postID
        }
        
        transform()
        print(#function, Self.desc)
    }
    
    deinit {
        print(#function, Self.desc)
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
        var category = ""
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
        if postMode == .create {
            output.presentedMessage = .success(msg: "게시글 작성이 완료되었습니다.")
        } else {
            output.presentedMessage = .success(msg: "게시글 수정이 완료되었습니다.")
        }
        
    }
    
}


// MARK: Activity Post
private extension PostViewModel {
    
    private func handleWritePostRequest() {
        Task {
            
            let videos = selectedMedia.filter { $0.type == .video } .compactMap { $0.videoURL }
            let images = selectedMedia.filter { $0.type == .image }.compactMap { $0.image }
            
            await MainActor.run { output.isLoading = true }
            let videoPath = await performUploadVideoIfNeeded(videos)
            let imagePath = await performUploadImageIfNeeded(images)

            if (videos.isEmpty || videoPath != nil) && (images.isEmpty || imagePath != nil) {
                let allPaths: [String] = (videoPath?.files ?? []) + (imagePath?.files ?? [])
                let success = await performWritePost(title: title, content: content, paths: allPaths)

                if success {
                    await MainActor.run {
                        handleSuccess()
                    }
                }
            }
            await MainActor.run { output.isLoading = false }
        }
    }
    
    
    private func performWritePost(title: String, content: String, paths: [String]) async -> Bool {
        do {
            guard let selectedActivity else { return false }
            guard let location = UserSession.shared.userLocation else { return false }

            let _ = try await writePostUseCase.execute(
                country: selectedActivity.country,
                category: selectedActivity.category,
                title: title,
                content: content,
                activity_id: selectedActivity.activityID,
                latitude: location.latitude,
                longitude: location.longitude,
                files: paths
            )


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
        
        if postMode == .create {
            guard selectedActivity != nil else {
                isConfirm = false
                return
            }
        }
        
        guard !title.isEmpty, !content.isEmpty else {
            isConfirm = false
            return
        }
        isConfirm = true
    }
    
}

// MARK: Modify
private extension PostViewModel {
    
    private func handleModifyPostRequest() {
        Task {
            
            let videos = selectedMedia.filter { $0.type == .video } .compactMap { $0.videoURL }
            let images = selectedMedia.filter { $0.type == .image }.compactMap { $0.image }
            
            await MainActor.run { output.isLoading = true }
            let videoPath = await performUploadVideoIfNeeded(videos)
            let imagePath = await performUploadImageIfNeeded(images)

            if (videos.isEmpty || videoPath != nil) && (images.isEmpty || imagePath != nil) {
                let allPaths: [String] = (videoPath?.files ?? []) + (imagePath?.files ?? [])
                print("here")
                let success = await performModifyPost(title: title, content: content, paths: allPaths)

                if success {
                    await MainActor.run {
                        handleSuccess()
                    }
                }
            }
            await MainActor.run { output.isLoading = false }
        }
    }
    
    private func performModifyPost(title: String, content: String, paths: [String]) async -> Bool {
        do {
            print("here2")
            let data = try await modifyPostUseCsae.execute(
                postID: postID,
                title: title,
                content: content,
                files: paths.isEmpty ? nil : paths
            )
            
            isModified = ModifyPost(
                postID: data.postID,
                title: data.title,
                content: data.content,
                files: data.files
            )
            return true

        } catch {
            await handleError(error)
            return false
        }
    }
    
}


// MARK: Activity Update
extension PostViewModel {
    
    private func handleActivityUpadte(_ activity: OrderList) {
        
        Task { @MainActor in
            output.activityTitle = activity.title
            output.country = activity.country
            output.category = activity.category
            selectedActivity = activity
        }
        
    }
    
}


//// MARK: Action
extension PostViewModel {
    
    enum Action {
        case acitivitySelected(activity: OrderList)
        case writePost
        
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .acitivitySelected(let activity):
            handleActivityUpadte(activity)
        case .writePost:
            if postMode == .create {
                handleWritePostRequest()
            } else {
                handleModifyPostRequest()
            }
            
            
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

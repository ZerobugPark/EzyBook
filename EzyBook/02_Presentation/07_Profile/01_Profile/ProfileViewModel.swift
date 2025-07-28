//
//  ProfileViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI
import Combine

final class ProfileViewModel: ViewModelType {
    
    private let profileUseCases: ProfileUseCases

    private let imageLoadUseCases: ImageLoadUseCases

    
    var input = Input()
    @Published var output = Output()
        
    var cancellables = Set<AnyCancellable>()
    
    private var scale: CGFloat
    
    init(
        profileUseCases: ProfileUseCases,
        imageLoadUseCases: ImageLoadUseCases,
        scale: CGFloat
 
    ) {
        self.profileUseCases = profileUseCases
        self.imageLoadUseCases = imageLoadUseCases
        self.scale = scale
    
        transform()
        handleInitProfileData()
    }
    
}

extension ProfileViewModel {
    
    struct Input { }
    
    struct Output {
        var isLoading = false
        
        var presentedMessage: DisplayMessage? = nil
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        /// 하나의 모델로 처리하기엔, UIImage랑 이미지 리소스랑 타입이 달라서 분리하는게 나을 듯
        var profile: ProfileLookUpModel = .skeleton
        
        var userCommerceInfo: (price: Int, reward: Int) = (0, 0)
    }
    
    func transform() { }
    
    //  supplementviewModel을 받아서 필요한 Output 값들 바인딩
    private func handleBindSupplement(_ supplement: ProfileSupplementaryViewModel) {
        supplement.$output
            .map { $0.presentedMessage }  // output안에 특정 값 호출
            .receive(on: DispatchQueue.main) // 메인스레드 보장
            .sink { [weak self] message in
                self?.output.presentedMessage = message
            }
            .store(in: &cancellables)
        
        
        supplement.$output
            .map { $0.userCommerceInfo }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] commerceInfo in
               
                self?.output.userCommerceInfo = commerceInfo
                
            }.store(in: &cancellables)
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


// MARK: Profile
extension ProfileViewModel {
    
    private func handleInitProfileData() {
        Task {
            await MainActor.run {
                output.isLoading = true
            }
            
            await fetchProfileLookup()
    
            
            await MainActor.run {
                output.isLoading = false
                
            }
        }
    }
    
    private func fetchProfileLookup() async {
        
        do {
            let data = try await profileUseCases.profileLookUp.execute()
        
            let profileImage: UIImage
        
            if !data.profileImage.isEmpty {
                profileImage = try await imageLoadUseCases.originalImage.execute(path: data.profileImage)
            } else  {
                profileImage = UIImage(resource: .tabBarProfileFill)
            }
            
            
            await MainActor.run {
                output.profile = ProfileLookUpModel(from: data, profileImage: profileImage)
            }
        } catch let error as APIError {
            await MainActor.run {
                output.presentedMessage = DisplayMessage.error(code: error.code, msg: error.userMessage)
            }
        } catch {
            print(error)
        }
    }
    

    
    private func handleDidSelectedImageData(_ image: UIImage) {
        Task {
            await MainActor.run {
                output.isLoading = true
            }
            
            await performMofiyUser(image)
          
            await MainActor.run {
                output.isLoading = false
                
            }
        }
    }
    
    private func performMofiyUser(_ image: UIImage) async {
        
          do {
              
              let path = try await requestUploadProfileImage(image)
              let data = try await performModifyUserImagePath(path)
       
              // 패스 기반 프로필 수정 추가
              let image = try await imageLoadUseCases.originalImage.execute(path: data.profileImage)
              
              await MainActor.run {
                  output.profile.profileImage = image
              }

          } catch {
              await handleError(error)
          }
          
    }
    
    // 패스 수정
    private func performModifyUserImagePath(_ path: UserImageUploadEntity) async throws ->  ProfileLookUpEntity {
        
        try await profileUseCases.profileModify.execute(
            nick: nil,
            profileImage: path.profileImage,
            phoneNum: nil,
            introduce: nil
        )
    }
    
}

extension ProfileViewModel {
    
    
    private func handleModifyProfile(data: ConfirmPayload) {
        Task {
            await perfromModifyProfile(data)
        }
    }
    
    @MainActor
    private func perfromModifyProfile(_ data: ConfirmPayload) {
        
        output.profile.introduction = data.intro.or(output.profile.introduction)
        output.profile.nick = data.nick.or(output.profile.nick)
        output.profile.phoneNum = data.phone.or(output.profile.phoneNum)
        
    }
    
}

// MARK: Helper
extension ProfileViewModel {
    
    /// 이미지 로드 함수
    private func requestThumbnailImage(_ path: String) async throws -> UIImage {

        return try await imageLoadUseCases.thumbnailImage.execute(path: path, scale: scale)
        
    }
    
    /// 이미지 업로드
    private func requestUploadProfileImage(_ image: UIImage) async throws ->  UserImageUploadEntity {
        
        return try await profileUseCases.profileUploadImage.execute(image: image)
        
    }
    
}

// MARK: Action
extension ProfileViewModel {
    
    enum Action {
        case didSelectedImageData(image: UIImage)
        case bindSupplement(ProfileSupplementaryViewModel)
        case modifyProfileData(ConfirmPayload)
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .didSelectedImageData(let image):
            handleDidSelectedImageData(image)
        case .bindSupplement(let supplement):
            handleBindSupplement(supplement)
        case .modifyProfileData(let payload):
            handleModifyProfile(data: payload)
        }
    }
    
    
}


// MARK: Alert 처리
extension ProfileViewModel: AnyObjectWithCommonUI {
    
    var isShowingError: Bool { output.isShowingMessage }
    var isShowingMessage: Bool { output.isShowingMessage }
    var presentedMessageTitle: String? { output.presentedMessage?.title }
    var presentedMessageBody: String? { output.presentedMessage?.message }
    var presentedMessageCode: Int? { output.presentedMessage?.code }
    
    func resetMessageAction() {
        output.presentedMessage = nil
    }
    
}

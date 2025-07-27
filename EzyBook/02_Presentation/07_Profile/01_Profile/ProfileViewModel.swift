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
    
    private var scale: CGFloat = 0
    
    init(
        profileUseCases: ProfileUseCases,
        imageLoadUseCases: ImageLoadUseCases,
 
    ) {
        self.profileUseCases = profileUseCases
        self.imageLoadUseCases = imageLoadUseCases
    
        transform()
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
    }
    
    func transform() { }
    
    //  supplementviewModel을 받아서 Alert 상태만 바인딩
    private func handleBindSupplement(_ supplement: ProfileSupplementaryViewModel) {
        supplement.$output
            .map { $0.presentedMessage }
            .receive(on: DispatchQueue.main) // 메인스레드 보장
            .sink { [weak self] message in
                self?.output.presentedMessage = message
            }
            .store(in: &cancellables)
    }
    
    private func handleProfileData() {
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
                //profileImage = try await imageLoader.execute(data.profileImage)
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
    
    /// 이미지 로드 함수
    private func requestThumbnailImage(_ path: String) async throws -> UIImage {

        return try await imageLoadUseCases.thumbnailImage.execute(path: path, scale: scale)
        
    }
    
    private func handleDidSelectedImageData(_ image: UIImage) {
        Task {
            await MainActor.run {
                output.isLoading = true
            }
            
          
            do {
                
                let path = try await requestUploadProfileImage(image)
                
                let data = try await profileUseCases.profileModify.execute(
                    nick: nil,
                    profileImage: path.profileImage,
                    phoneNum: nil,
                    introduce: nil
                )
  
                
                // 패스 기반 프로필 수정 추가
                let image = try await imageLoadUseCases.originalImage.execute(path: data.profileImage)
                //imageLoader.execute(data.profileImage)
                
                await MainActor.run {
                    output.profile.profileImage = image
                }

              } catch let error as APIError {
                  await MainActor.run {
                      output.presentedMessage = DisplayMessage.error(code: error.code, msg: error.userMessage)
                  }
              } catch {
                  print(error)
              }
            
            await MainActor.run {
                output.isLoading = false
                
            }
        }
    }
    
    private func requestUploadProfileImage(_ image: UIImage) async throws ->  UserImageUploadEntity {
        
        return try await profileUseCases.profileUploadImage.execute(image: image)
        
    }
   
    
    private func handleUpdateScale(_ scale: CGFloat) {
        self.scale = scale
    }
    
}

// MARK: Action
extension ProfileViewModel {
    
    enum Action {
        case onAppearRequested
        case updateScale(scale: CGFloat)
        case didSelectedImageData(image: UIImage)
        case bindSupplement(ProfileSupplementaryViewModel)
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .onAppearRequested:
            handleProfileData()
        case .updateScale(let scale):
            handleUpdateScale(scale)
        case .didSelectedImageData(let image):
            handleDidSelectedImageData(image)
        case .bindSupplement(let supplement):
            handleBindSupplement(supplement)
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

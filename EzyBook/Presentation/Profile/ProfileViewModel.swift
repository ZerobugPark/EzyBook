//
//  ProfileViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 6/9/25.
//

import SwiftUI
import Combine

final class ProfileViewModel: ViewModelType {
    
    private let profileLookUpUseCase: DefaultProfileLookUpUseCase
    private let imageLoader: DefaultLoadImageUseCase
    private let uploadImageUseCase: DefaultUploadFileUseCase
    private let profileModifyUseCase: DefaultProfileModifyUseCase
    
    var input = Input()
    @Published var output = Output()
        
    var cancellables = Set<AnyCancellable>()
    
    private var scale: CGFloat = 0
    
    init(
        profileLookUpUseCase: DefaultProfileLookUpUseCase,
        imageLoader: DefaultLoadImageUseCase,
        uploadImageUsecase: DefaultUploadFileUseCase,
        profileModifyUseCase: DefaultProfileModifyUseCase
    ) {
        self.profileLookUpUseCase = profileLookUpUseCase
        self.imageLoader = imageLoader
        self.uploadImageUseCase = uploadImageUsecase
        self.profileModifyUseCase = profileModifyUseCase
        transform()
    }
    
}

extension ProfileViewModel {
    
    struct Input { }
    
    struct Output {
        var isLoading = false
        
        var presentedError: DisplayError? = nil
        var isShowingError: Bool {
            presentedError != nil
        }
        /// 하나의 모델로 처리하기엔, UIImage랑 이미지 리소스랑 타입이 달라서 분리하는게 나을 듯
        var profile: ProfileLookUpModel = .skeleton
    }
    
    func transform() { }
    
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
            let data = try await profileLookUpUseCase.execute()
            print("profile",data)
            let profileImage: UIImage
        
            if !data.profileImage.isEmpty {
                profileImage = try await imageLoader.execute(data.profileImage)
            } else  {
                profileImage = UIImage(resource: .tabBarProfileFill)
            }
            
            await MainActor.run {
                output.profile = ProfileLookUpModel(from: data, profile: profileImage)
            }
        } catch let error as APIError {
            await MainActor.run {
                output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
            }
        } catch {
            print(error)
        }
    }
    
    /// 이미지 로드 함수
    private func requestThumbnailImage(_ path: String) async throws -> UIImage {
        
        return try await imageLoader.execute(path, scale: scale)
        
    }
    
    private func handleDidSelectedImageData(_ image: UIImage) {
        Task {
            await MainActor.run {
                output.isLoading = true
            }
            
          
            do {
                let path = try await requestUploadProfileImage(image)
                
                
                let data = try await profileModifyUseCase.execute(
                    ProfileModifyRequestDTO(nick: nil, profileImage: path.profileImage, phoneNum: nil, introduction: nil)
                )
                
                // 패스 기반 프로필 수정 추가
                let image = try await imageLoader.execute(data.profileImage)
                
                await MainActor.run {
                    output.profile.profileImage = image
                }

              } catch let error as APIError {
                  await MainActor.run {
                      output.presentedError = DisplayError.error(code: error.code, msg: error.userMessage)
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
        
        return try await uploadImageUseCase.execute(image)
        
    }
    
    private func handleResetError() {
        output.presentedError = nil
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
        case resetError
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
        case .resetError:
            handleResetError()
 
        }
    }
    
    
}


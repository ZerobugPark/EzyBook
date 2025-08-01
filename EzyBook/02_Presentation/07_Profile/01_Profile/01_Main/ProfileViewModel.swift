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
    
    var input = Input()
    @Published var output = Output()
        
    var cancellables = Set<AnyCancellable>()

    init(
        profileUseCases: ProfileUseCases,
 
    ) {
        self.profileUseCases = profileUseCases

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
        var profile: ProfileLookUpEntity = .skeleton
        
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
           
            await MainActor.run { output.profile = data }
        } catch {
            await handleError(error)
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
            
              await MainActor.run {
                  output.profile = data
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
    
    
    private func handleModifyProfile(data: ProfileLookUpEntity?) {
        Task {
            if let data {
                await perfromModifyProfile(data)
            }
            
        }
    }
    
    @MainActor
    private func perfromModifyProfile(_ data: ProfileLookUpEntity) {
        output.profile = data
    }
    
}

// MARK: Helper
extension ProfileViewModel {
    
 
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
        case modifyProfileData(ProfileLookUpEntity?)
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
    func action(_ action: Action) {
        switch action {
        case .didSelectedImageData(let image):
            handleDidSelectedImageData(image)
        case .bindSupplement(let supplement):
            handleBindSupplement(supplement)
        case .modifyProfileData(let entity):
            handleModifyProfile(data: entity)
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

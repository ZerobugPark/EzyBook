//
//  ProfileModifyViewModel.swift
//  EzyBook
//
//  Created by youngkyun park on 7/28/25.
//

import SwiftUI
import Combine



final class ProfileModifyViewModel: ViewModelType {
    
    var input = Input()
    @Published var output = Output()
    
        
    var cancellables = Set<AnyCancellable>()
    
    private let useCase: ProfileModifyUseCase
    
    
    init(useCase: ProfileModifyUseCase) {
        self.useCase = useCase
        transform()
    }
    
}

// MARK: Input/Output
extension ProfileModifyViewModel {
        

    struct Input {
        var nicknameTextField = ""
        var phoneNumberTextField = ""
        var introduceTextField = ""
    }
    
    struct Output {
        /// 뷰의 상태 표시
        var isValidNickname = false
        
        var isValidPhoneNumber = false
        var presentedMessage: DisplayMessage? = nil
        
        var isShowingMessage: Bool {
            presentedMessage != nil
        }
        var userPayload: ProfileLookUpEntity?
    }
    
    func transform() { }
    
    
    /// 이거 특정 뷰모델로 처리해도 괜찮지 않을까?
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
        output.presentedMessage = .success(msg: "프로필 수정이 완료되었습니다.")
    }
    


}

// MARK: NickName TextField
extension ProfileModifyViewModel {
    
    /// Validates NickName
    private func handleNicknameEditingCompleted() {
        output.isValidNickname = isNicknameLocallyValid(input.nicknameTextField)
    }
    
    /// 유저 닉네임 유효성 검사
    private func isNicknameLocallyValid(_ nickname: String) -> Bool {
        //유효한 특수문자
        let forbiddenCharacters: Set<Character> = [",", ".", "?", "*", "-", "@"]
        let trimmed = nickname.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty else { return false }
        if trimmed.count == 1, let first = trimmed.first, forbiddenCharacters.contains(first) {
            return false
        }
        return true
    }

    
}

// MARK: Phone Text Field
extension ProfileModifyViewModel {
    

    /// Checks if the given phone number is valid (e.g., exactly 11 digits, etc.)
    private func isPhoneNumberValid(_ phoneNumber: String) -> Bool {
        // 1. 11자리, 2. 모두 숫자, 3. 01로 시작
        phoneNumber.count == 11 &&
        phoneNumber.hasPrefix("01") &&
        phoneNumber.allSatisfy { $0.isNumber }
    }
    
    /// Validate Phone Number
    private func handlePhoneNumberEditingCompleted() {
        output.isValidPhoneNumber = isPhoneNumberValid(input.phoneNumberTextField)
    }
    
}


// MARK: SignUp Button Tapped (수정하기 버튼 클릭)
extension ProfileModifyViewModel {
    
    
    private func handleModifyButtonTapped() {
        Task {
            await performModifyRequest()
        }
    }
    
    private func performModifyRequest() async {
        
        do {
            let data = try await useCase.execute(
                nick: input.nicknameTextField,
                profileImage: nil,
                phoneNum: input.phoneNumberTextField.isEmpty ? nil : input.phoneNumberTextField,
                introduce: input.introduceTextField.isEmpty ? nil : input.introduceTextField,
            )
            
            output.userPayload = data
            
            await MainActor.run {
                handleSuccess()
                
            }
        } catch {
            
            await handleError(error)
        }
        
    }

    
}



// MARK: Action
extension ProfileModifyViewModel {
    
    enum Action {
        case nickNameEditingCompleted
        case phoneNumberEditingCompleted
        case modifyButtonTapped
    }
    
    /// handle: ~ 함수를 처리해 (액션을 처리하는 함수 느낌으로 사용)
        func action(_ action: Action) {
        switch action {
        case .nickNameEditingCompleted:
            handleNicknameEditingCompleted()
        case .phoneNumberEditingCompleted:
            handlePhoneNumberEditingCompleted()
        case .modifyButtonTapped:
            handleModifyButtonTapped()
        }
    }
    
    
}

// MARK: Alert 처리
extension ProfileModifyViewModel: AnyObjectWithCommonUI {
    
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


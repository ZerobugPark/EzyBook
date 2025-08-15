//
//  ProfileModifyView.swift
//  EzyBook
//
//  Created by youngkyun park on 7/27/25.
//

import SwiftUI


struct ProfileModifyView: View {
    
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: ProfileModifyViewModel
    private let onConfirm: (ProfileLookUpEntity?) -> Void
    

    @FocusState private var focusedField: SignUpFocusField?
    @State private var lastFocusedField: SignUpFocusField?
    
    
    init(viewModel: ProfileModifyViewModel, onConfirm: @escaping (ProfileLookUpEntity?) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onConfirm = onConfirm

    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            CommonNavigationBar(
                title: "프로필 수정", leadingAction: {
                    dismiss()
                })
            nicknameField()
            phonNumberField()
            introduceField()
            
            Spacer()
            PrimaryActionButton(
                title: "수정",
                isEnabled: viewModel.output.isValidNickname
            ) {
                viewModel.action(.modifyButtonTapped)
            }
        }
        .withCommonUIHandling(viewModel) { code, isSuccess in
            if isSuccess {
                onConfirm(viewModel.output.userPayload)
                dismiss()
            } else if code == 418 {
                appState.isLoggedIn = false
            }
        }
        .onChange(of: focusedField) { newValue in
            
            if let last = lastFocusedField, newValue != last {
                validateLastFocusedField(last)
            }
            lastFocusedField = newValue
        }
        .padding(.horizontal)
        
        
    }
}



// MARK: NickNameField {
extension ProfileModifyView {
    private func nicknameField() -> some View {
        
        SignUpInputField(
            title: SignUpMessage.Title.nickname,
            placeholder: SignUpMessage.Placeholder.nickname,
            text: $viewModel.input.nicknameTextField,
            isRequired: true,
            focusField: $focusedField,
            field: .nickname,
            onSubmit: {
                viewModel.action(.nickNameEditingCompleted)
            },
            validations: [
                .init(message:  SignUpMessage.Validation.validNickname, isValid: viewModel.output.isValidNickname)
            ]
        )
    }
}

// MARK: Phone Number {
extension ProfileModifyView {
    private func phonNumberField() -> some View {
        
        SignUpInputField(
            title: SignUpMessage.Title.phone,
            placeholder: SignUpMessage.Placeholder.phone,
            text: $viewModel.input.phoneNumberTextField,
            isRequired: false,
            focusField: $focusedField,
            field: .phone,
            onSubmit: {
                viewModel.action(.phoneNumberEditingCompleted)
            },
            validations: [
                .init(
                    message: SignUpMessage.Validation.validPhone,
                    isValid: viewModel.output.isValidPhoneNumber
                )
            ]
        )
        
    }
}

// MARK: Introduce {
extension ProfileModifyView {
    
    private func introduceField() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            FieldTitle(title: SignUpMessage.Title.introduce, isRequired: false)
            TextEditor(text: $viewModel.input.introduceTextField)
                .frame(height: 150) // Set the height for the text input area
                .cornerRadius(15) // 모서리 둥글게 하기
                .border(Color.grayScale60.opacity(0.5), width: 1) // 테두리 추가
        }
    }
    
    private func validateLastFocusedField(_ field: SignUpFocusField) {
        switch field {
        case .nickname where !viewModel.input.nicknameTextField.isEmpty:
            viewModel.action(.nickNameEditingCompleted)
        case .phone where !viewModel.input.phoneNumberTextField.isEmpty:
            viewModel.action(.phoneNumberEditingCompleted)
        default:
            break
        }
    }
    
    
}

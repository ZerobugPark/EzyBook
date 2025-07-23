//
//  CreateAccountView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI

struct CreateAccountView: View {
    
    @Binding var selectedIndex: Int
    @ObservedObject var viewModel: CreateAccountViewModel
    
    @FocusState private var focusedField: SignUpFocusField?
    @State private var lastFocusedField: SignUpFocusField?
    
    // 비밀번호 히든 체크
    @State var visibleStates: [PasswordInputFieldType: Bool] = [
        .password: false,
        .confirmPassword: false
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                emailField()
                passwordField()
                nicknameField()
                phonNumberField()
                introduceField()
                signUpButton()
                
    
                backButton
                
            }
            .padding(.horizontal)

        }
        .commonAlert(
            isPresented: Binding(
                get: { viewModel.output.isShowingError },
                set: { isPresented in
                    if !isPresented {
                        viewModel.action(.resetError)
                    }
                }
            ),
            title: viewModel.output.currentError?.message.title,
            message: viewModel.output.currentError?.message.msg
        )
        .commonAlert(
            isPresented: $viewModel.output.isAccountCreated,
            title: "안내",
            message: "회원가입이 완료되었습니다.") {
                withAnimation(.easeInOut) {
                    selectedIndex = 0
                }
        }
        .onChange(of: focusedField) { newValue in
            
            if let last = lastFocusedField, newValue != last {
                validateLastFocusedField(last)
            }
            lastFocusedField = newValue
        }
        .onDisappear {
            focusedField = nil
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
    }
    
    /// 로그인 화면 이동
    private var backButton: some View {
        Button {
            withAnimation(.easeInOut) {
                selectedIndex = 0
            }
        } label: {
            Text("< 로그인 해주세요")
                .appFont(PaperlogyFontStyle.caption, textColor: .grayScale75)
        }
        .padding([.top, .bottom], 20)
    }
    
    
}

// MARK:  Email TextField
extension CreateAccountView {
    
    private func emailField() -> some View {
        VStack(alignment: .leading) {
            fieldTitle(SignUpMessage.Title.email, required: true)
            
 
            TextField(
                SignUpMessage.Placeholder.email,
                text: $viewModel.input.emailTextField
            )
                .textFieldModify()
                .appFont(PretendardFontStyle.body1, textColor: .grayScale100)
                .focused($focusedField, equals: .email)
                .onSubmit {
                    viewModel.action(.emailEditingCompleted)
                }
            
            
            validationMessage(
                SignUpMessage.Validation.validEmail,
                isValid: $viewModel.output.isVaildEmail)
            
            validationMessage(
                SignUpMessage.Validation.possibleEmail,
                isValid: $viewModel.output.isAvailableEmail
            )
            
        }
    }
    

}

// MARK: PasswordField
extension CreateAccountView {
    
    private func passwordField() -> some View {
        VStack(alignment: .leading) {
            fieldTitle(SignUpMessage.Title.password, required: true)
                .padding(.bottom, 5)
            

            // MARK: Fliker 현상 발생
            // https://github.com/facebook/react-native/issues/39411
            // 다들 문제가 조금씩 있는거 같은데
            passwordTextField(type: .password, focusedField: $focusedField)
            passwordTextField(type: .confirmPassword, focusedField: $focusedField)
                
            
            validationMessage(SignUpMessage.Validation.passwordComplex, isValid: $viewModel.output.isPasswordComplexEnough)
            
            validationMessage(SignUpMessage.Validation.passwordLength, isValid: $viewModel.output.isPasswordLongEnough)
    
            
            validationMessage(SignUpMessage.Validation.passwordMatch, isValid: $viewModel.output.isValidPassword)
            
         
            
        }
    }
    

    private func passwordTextField(type: PasswordInputFieldType, focusedField: FocusState<SignUpFocusField?>.Binding) -> some View{
        let passwordFieldInfo = getPasswordBinding(for: type)
        
        return HStack {
            ZStack(alignment: .trailing) {
                Group {
                    if visibleStates[type] == true {
                        TextField(passwordFieldInfo.title, text: passwordFieldInfo.binding)
                            .textFieldModify()
                            .appFont(PretendardFontStyle.body1)
                            .focused(focusedField, equals: type.toField())
                    } else {
                        SecureField(passwordFieldInfo.title, text: passwordFieldInfo.binding)
                            .textFieldModify()
                            .appFont(PretendardFontStyle.body1)
                            .focused(focusedField, equals: type.toField())
                    }
                }
                
                Button {
                    visibleStates[type]?.toggle()
                } label: {
                    Image(systemName: visibleStates[type] == true ?  "eye" : "eye.slash")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
            }
            .frame(height: 50)
        }
        .onSubmit {
            switch type {
            case .password:
                viewModel.action(.passwordEditingCompleted)
            case .confirmPassword:
                viewModel.action(.passwordEditingCompleted)
            }
        }
        
    }
    
    private func getPasswordBinding(for type: PasswordInputFieldType) -> (title: String, binding: Binding<String>) {
        switch type {
        case .password:
            return (SignUpMessage.Placeholder.password ,$viewModel.input.passwordTextField)
        case .confirmPassword:
            return (SignUpMessage.Placeholder.confirmPassword, $viewModel.input.passwordConfirmTextField)
        }
    }
}


// MARK: NickNameField {
extension CreateAccountView {
    private func nicknameField() -> some View {
        VStack(alignment: .leading) {
            fieldTitle(SignUpMessage.Title.nickname, required: true)
            TextField(SignUpMessage.Placeholder.nickname, text: $viewModel.input.nicknameTextField)
                .textFieldModify()
                .appFont(PretendardFontStyle.body1)
                .focused($focusedField, equals: .nickname)
                .onSubmit { viewModel.action(.nickNameEditingCompleted) }
            
            validationMessage(
                SignUpMessage.Validation.validNickname,
                isValid: $viewModel.output.isValidNickname
            )
            
        }
    }
}

// MARK: Phone Number {
extension CreateAccountView {
    private func phonNumberField() -> some View {
        VStack(alignment: .leading) {
            fieldTitle(SignUpMessage.Title.phone)
            TextField(SignUpMessage.Placeholder.phone, text: $viewModel.input.phoneNumberTextField)
                .textFieldModify()
                .appFont(PretendardFontStyle.body1)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .phone)
                .onSubmit {
                    viewModel.action(.phoneNumberEditingCompleted)
                }
            
            validationMessage(SignUpMessage.Validation.validPhone, isValid: $viewModel.output.isValidPhoneNumber)
      
                
        }
    }
}

// MARK: Introduce {
extension CreateAccountView {
    
    private func introduceField() -> some View {
        VStack(alignment: .leading) {
            fieldTitle(SignUpMessage.Title.introduce)
            TextEditor(text: $viewModel.input.introduceTextField)
                .frame(height: 150) // Set the height for the text input area
                .cornerRadius(15) // 모서리 둥글게 하기
                .border(Color.grayScale60.opacity(0.5), width: 1) // 테두리 추가
        }
    }
    
 
}

// MARK: SignUpButton {
extension CreateAccountView {
    private func signUpButton() -> some View {
        Button {
            viewModel.action(.signUpButtonTapped)
        } label: {
            Text("회원가입")
                .frame(maxWidth: .infinity)
                .padding()
                .background(.deepSeafoam)
                .clipShape(Capsule())
                .appFont(PaperlogyFontStyle.body, textColor: .white)
        }
        .opacity(viewModel.output.isFormValid ? 1 : 0.5)
        .disabled(!viewModel.output.isFormValid)
        
    }
}


// MARK: Common Component
extension CreateAccountView {
    
    
    private func validationMessage(_ message: String, isValid: Binding<Bool>) -> some View {
        Text(message)
            .appFont(PretendardFontStyle.caption1)
            .vaildTextdModify(isValid.wrappedValue)
    }
    
    
    private func fieldTitle(_ title: String, required: Bool = false) -> some View {
        HStack(spacing: 2) {
            Text(title)
                .appFont(PretendardFontStyle.body1)
            if required {
                Text("*")
                    .foregroundColor(.red)
                    .appFont(PretendardFontStyle.body2)
            }
        }
    }
    
    private func validateLastFocusedField(_ field: SignUpFocusField) {
        switch field {
        case .email where !viewModel.input.emailTextField.isEmpty:
            viewModel.action(.emailEditingCompleted)
        case .password where !viewModel.input.passwordTextField.isEmpty:
            viewModel.action(.passwordEditingCompleted)
        case .confirmPassword where !viewModel.input.passwordConfirmTextField.isEmpty:
            viewModel.action(.passwordEditingCompleted)
        case .nickname where !viewModel.input.nicknameTextField.isEmpty:
            viewModel.action(.nickNameEditingCompleted)
        case .phone where !viewModel.input.phoneNumberTextField.isEmpty:
            viewModel.action(.phoneNumberEditingCompleted)
        default:
            break
        }
    }
    
}

enum SignUpMessage {
    
    enum Title {
        static let email = "이메일"
        static let password = "비밀번호"
        static let nickname = "닉네임"
        static let phone = "전화번호"
        static let introduce = "소개"
    }
    
    enum Placeholder {
        static let email = "이메일을 입력해주세요"
        static let password = "비밀번호를 입력해 주세요"
        static let confirmPassword = "비밀번호를 다시 입력해 주세요"
        static let nickname = "닉네임을 입력해주세요"
        static let phone = "전화번호를 입력해주세요"
    }
    
    enum Validation {
        static let validEmail = "✓ 유효한 이메일 형식입니다."
        static let possibleEmail = "✓ 사용 가능한 이메일입니다."
        static let passwordComplex = "✓ 영문자, 숫자, 특수문자(@$!%*#?&)를 각각 1개 이상 포함해야 합니다."
        static let passwordLength = "✓ 최소 글자 수는 8자 이상입니다."
        static let passwordMatch = "✓ 비밀번호가 일치합니다."
        static let validNickname = "✓ , ,, ?, *, -, @는 nick으로 사용할 수 없습니다."
        static let validPhone = "✓ 유효한 형식입니다."
    }
}


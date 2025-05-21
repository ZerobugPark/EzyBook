//
//  CreateAccountView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI

struct CreateAccountView: View {
    
    @Binding var selectedIndex: Int
    @StateObject var viewModel: CreateAccountViewModel
    
    @FocusState private var focusedField: FocusField?
    @State private var lastFocusedField: FocusField?
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                emailField()
                passwordField()
                nicknameField()
                phonNumberField()
                introduceField()
                signUpButton()
                
                Button {
                    withAnimation(.easeInOut) {
                        selectedIndex = 0
                    }
                } label: {
                    Text("< 로그인 해주세요")
                }
                
            }
            .padding(.horizontal)
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
        }
        .onChange(of: focusedField) { newValue in
            
            if let last = lastFocusedField, newValue != last {
                validateLastFocusedField(last)
            }
            
            // 현재 포커스 상태 저장 (nil 포함)
            lastFocusedField = newValue
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
    }
    
    
}

// MARK: CustomView
extension CreateAccountView {
    
    private func emailField() -> some View {
        VStack(alignment: .leading) {
            fieldTitle("이메일", required: true)
            TextField("이메일을 입력해주세요.", text: $viewModel.input.emailTextField)
                .textFieldModify()
                .focused($focusedField, equals: .email)
                .onSubmit { viewModel.action(.emailEditingCompleted) }
            
            Text("✓ 유효한 이메일 형식입니다.")
                .vaildTextdModify(viewModel.output.isVaildEmail)
            Text("✓ 사용 가능한 이메일입니다.")
                .vaildTextdModify(viewModel.output.isAvailableEmail)
            
        }
    }
    
    private func passwordField() -> some View {
        VStack(alignment: .leading) {
            fieldTitle("비밀번호", required: true)
            passwordTextField(type: .password, focusedField: $focusedField)
            passwordTextField(type: .confirmPassword, focusedField: $focusedField)
                .padding(.top, 5)
            
            Text("✓ 영문자, 숫자, 특수문자(@$!%*#?&)를 각각 1개 이상 포함해야 합니다.")
                .vaildTextdModify(viewModel.output.isPasswordComplexEnough)
            Text("✓ 최고 글자 수는 8자 이상입니다.")
                .vaildTextdModify(viewModel.output.isPasswordLongEnough)
            Text("✓ 비밀번호가 일치합니다.")
                .vaildTextdModify(viewModel.output.isValidPassword)
            
        }
    }
    
    private func passwordTextField(type: PasswordInputFieldType, focusedField: FocusState<FocusField?>.Binding) -> some View{
        let passwordFieldInfo = getPasswordBinding(for: type)
        
        return HStack {
            ZStack(alignment: .trailing) {
                Group {
                    if viewModel.output.visibleStates[type] == true {
                        TextField(passwordFieldInfo.title, text: passwordFieldInfo.binding)
                            .textFieldModify()
                            .focused(focusedField, equals: type.toField())
                    } else {
                        SecureField(passwordFieldInfo.title, text: passwordFieldInfo.binding)
                            .textFieldModify()
                            .focused(focusedField, equals: type.toField())
                    }
                }
                
                Button {
                    viewModel.action(.togglePasswordVisibility(type: type))
                } label: {
                    Image(systemName: viewModel.output.visibleStates[type] == true ?  "eye" : "eye.slash")
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
            return ("비밀번호를 입력해 주세요" ,$viewModel.input.passwordTextField)
        case .confirmPassword:
            return ("비밀번호를 다시 입력해 주세요", $viewModel.input.passwordConfirmTextField)
        }
    }
    
    private func nicknameField() -> some View {
        VStack(alignment: .leading) {
            fieldTitle("닉네임", required: true)
            TextField("닉네임을 입력해주세요", text: $viewModel.input.nicknameTextField)
                .textFieldModify()
                .focused($focusedField, equals: .nickname)
                .onSubmit { viewModel.action(.nickNameEditingCompleted) }
            
            
            Text("✓ , ,, ?, *, -, @는 nick으로 사용할 수 없습니다.")
                .vaildTextdModify(viewModel.output.isValidNickname)
        }
    }
    
    private func phonNumberField() -> some View {
        VStack(alignment: .leading) {
            fieldTitle("전화번호")
            TextField("전화번호를 입력해주세요", text: $viewModel.phoneNumberTextField)
                .textFieldModify()
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .phone)
                .onChange(of: viewModel.phoneNumberTextField) { newValue in
                    let digitsOnly = newValue.filter { $0.isNumber }
                    let limited = String(digitsOnly.prefix(11))
                    
                    // 변경된 값이 있으면 업데이트
                    if newValue != limited {
                        viewModel.phoneNumberTextField = limited
                    }
                }
                .onSubmit {
                    viewModel.action(.phoneNumberEditingCompleted)
                }
            Text("✓ 유효한 형식입니다.")
                .vaildTextdModify(viewModel.output.isValidPhoneNumber)
            
            
        }
        
    }
    
    private func introduceField() -> some View {
        VStack(alignment: .leading) {
            fieldTitle("소개")
            TextEditor(text: $viewModel.input.introduceTextField)
                .frame(height: 150) // Set the height for the text input area
                .cornerRadius(15) // 모서리 둥글게 하기
                .border(Color.grayScale60.opacity(0.5), width: 1) // 테두리 추가
        }
    }
    
    private func signUpButton() -> some View {
        Button {
            viewModel.action(.signUpButtonTapped)
        } label: {
            Text("회원가입")
                .foregroundColor(.white)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .clipShape(Capsule())
        }
        .opacity(viewModel.output.isFormValid ? 1 : 0.5)
        .disabled(!viewModel.output.isFormValid)
        
    }
    
    private func fieldTitle(_ title: String, required: Bool = false) -> some View {
        HStack(spacing: 2) {
            Text(title)
                .font(.headline)
            if required {
                Text("*")
                    .foregroundColor(.red)
                    .font(.headline)
            }
        }
    }
    
   
    private func validateLastFocusedField(_ field: FocusField) {
        switch field {
        case .email:
            viewModel.action(.emailEditingCompleted)
        case .password:
            viewModel.action(.passwordEditingCompleted)
        case .confirmPassword:
            viewModel.action(.passwordEditingCompleted)
        case .nickname:
            viewModel.action(.nickNameEditingCompleted)
        case .phone:
            viewModel.action(.phoneNumberEditingCompleted)
        }
    }
    
}

#Preview {
    PreViewHelper.makeCreateAccountView()
}

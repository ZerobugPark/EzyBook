//
//  CreateAccountView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI

struct CreateAccountView: View {
    
    @StateObject var viewModel: CreateAccountViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    emailField()
                    passwordField()
                    nicknameField()
                    phonNumberField()
                    introduceField()
                    signUpButton()
                }
            }
            .navigationTitle("회원가입")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.input.passwordTextField = ""
        }
        
    }
    
    
}

// MARK: CustomView
extension CreateAccountView {
    
    private func emailField() -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 2) {
                Text("이메일")
                    .font(.headline)
                Text("*")
                    .foregroundColor(.red)
                    .font(.headline)
            }
            TextField("이메일을 입력해주세요.", text: $viewModel.input.emailTextField)
                .textFieldModify()
                .onSubmit {
                    viewModel.action(.emailEditingCompleted)
                }
            
            //todo: isVaildEmail 이거 분리 처리할 거
            Text("✓ 유효한 이메일 형식입니다.")
                .vaildTextdModify(viewModel.output.isVaildEmail)
            Text("✓ 사용 가능한 이메일입니다.")
                .vaildTextdModify(viewModel.output.isAvailableEmail)
            
            
        }
        .padding()
        
    }
   
    private func passwordField() -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 2) {
                Text("비밀번호")
                    .font(.headline)
                Text("*")
                    .foregroundColor(.red)
                    .font(.headline)
            }
            passwordTextField(type: .password)
            
            passwordTextField(type: .confirm)
                .padding(.top, 5)
            
            Text("✓ 영문자, 숫자, 특수문자(@$!%*#?&)를 각각 1개 이상 포함해야 합니다.")
                .vaildTextdModify(viewModel.output.isPasswordComplexEnough)
            Text("✓ 최고 글자 수는 8자 이상입니다.")
                .vaildTextdModify(viewModel.output.isPasswordLongEnough)
            Text("✓ 비밀번호가 일치합니다.")
                .vaildTextdModify(viewModel.output.isValidPassword)
            
        }
        .padding()
        
    }
    
    private func passwordTextField(type: PasswordField) -> some View{
        
        let textfield = getPasswordBinding(for: type)
        
        return HStack {
            ZStack(alignment: .trailing) {
                Group {
                    if viewModel.output.visibleStates[type] == true {
                        TextField(textfield.title, text: textfield.binding)
                            .textFieldModify()
                        
                        
                    } else {
                        SecureField(textfield.title, text: textfield.binding)
                            .textFieldModify()
                    }
                    
                }
                
                Button {
                    viewModel.action(.togglePasswordVisibility(type: type))
                } label: {
                    Image(systemName: viewModel.output.visibleStates[type] == true ?  "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
            }
        }
        .onSubmit {
            switch type {
            case .password:
                viewModel.action(.passwordEditingCompleted)
            case .confirm:
                viewModel.action(.passwordConfirmEditingCompleted)
            }
         
        }
        
    }
    
    private func getPasswordBinding(for type: PasswordField) -> (title: String, binding: Binding<String>) {
        switch type {
        case .password:
            return ("비밀번호를 입력해 주세요" ,$viewModel.input.passwordTextField)
        case .confirm:
            return ("비밀번호를 다시 입력해 주세요", $viewModel.input.passwordConfirmTextField)
        }
    }
    
    private func nicknameField() -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 2) {
                Text("닉네임")
                    .font(.headline)
                Text("*")
                    .foregroundColor(.red)
                    .font(.headline)
            }
            TextField("닉네임을 입력해주세요", text: $viewModel.input.nicknameTextField)
                .textFieldModify()
                .onSubmit {
                    viewModel.action(.nickNameEditingCompleted)
                }
            
            
            Text("✓ , ,, ?, *, -, @는 nick으로 사용할 수 없습니다.")
                .vaildTextdModify(viewModel.output.isValidNickname)
        }
        .padding()
        
    }
    
    private func phonNumberField() -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 2) {
                Text("전화번호")
                    .font(.headline)
            }
            TextField("전화번호를 입력해주세요", text: $viewModel.phoneNumberTextField)
                .textFieldModify()
                .keyboardType(.numberPad)
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
        .padding()
        
    }
    
    private func introduceField() -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 2) {
                Text("소개")
                    .font(.headline)
            }
            TextEditor(text: $viewModel.input.introduceTextField)
                .frame(height: 150) // Set the height for the text input area
                .cornerRadius(15) // 모서리 둥글게 하기
                .border(Color.grayScale60.opacity(0.5), width: 1) // 테두리 추가
        }
        .padding()

    }
    
    private func signUpButton() -> some View {
        Button {
            print("button Tapped")
        } label: {
            Text("회원가입")
                .foregroundColor(.white)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .clipShape(Capsule())
        }
        .padding()
      
    }
    
}

//#Preview {
//    CreateAccountView()
//}

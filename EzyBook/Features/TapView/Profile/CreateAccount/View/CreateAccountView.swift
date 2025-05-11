//
//  CreateAccountView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI

struct CreateAccountView: View {
    
    @StateObject private var viewModel = CreateAccountViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    emailField()
                    passwordField()
                }
            }
            .navigationTitle("회원가입")
            .navigationBarTitleDisplayMode(.inline)
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
            
            Text("✓ 유효한 이메일 형식입니다.")
                .vaildTextdModify(viewModel.output.isVaildEmail)
            
            
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
            
            
            //4. 비밀번호는 최소 8자 이상이며, 영문자, 숫자, 특수문자(@$!%*#?&)를 각각 1개 이상 포함해야 합니다.
            Text("✓ 영문자, 숫자, 특수문자(@$!%*#?&)를 각각 1개 이상 포함")
                .vaildTextdModify(viewModel.output.isPasswordComplexEnough)
            Text("✓ 8자 이상")
                .vaildTextdModify(viewModel.output.isPasswordLongEnough)
            Text(viewModel.output.isValidPassword ? "✓ 비밀번호 일치" : "✓ 비밀번호가 일치하지 않습니다")
                .vaildTextdModify(viewModel.output.isValidPassword)
            
        }
        .padding()
        
    }
    
    private func passwordTextField(type: PasswordField) -> some View{
        
        let textfield = getPasswordBinding(for: type)
        
        return HStack {
            ZStack(alignment: .trailing) {  // 텍스트 필드 위에 버튼을 올리기 위한 ZStack 사용
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
                .padding(.trailing, 8)  // 버튼과 텍스트필드 사이 간격을 조정
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
            return ("비밀번호를 입력해 주세요" ,$viewModel.input.inputPassword)  // 비밀번호 바인딩
        case .confirm:
            return ("비밀번호를 다시 입력해 주세요", $viewModel.input.inputPasswordConfirm)  // 비밀번호 확인 바인딩
        }
    }
}

#Preview {
    CreateAccountView()
}

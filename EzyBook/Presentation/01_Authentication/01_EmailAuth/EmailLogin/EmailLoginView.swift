//
//  EmailLoginView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/17/25.
//

import SwiftUI

struct EmailLoginView: View {
    
    @Binding var selectedIndex: Int
    @ObservedObject var viewModel: EmailLoginViewModel

    @ObservedObject var coordinator: AuthCoordinator
    
    @FocusState private var isFocused: LoginInputFieldType?
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            FloatingLabelTextField(
                title: "이메일",
                text: $viewModel.input.emailTextField,
                isFocused: $isFocused,
                currentField: .email
            )
            
            FloatingLabelSecureField(
                title: "비밀번호",
                text: $viewModel.input.passwordTextField,
                isFocused: $isFocused,
                currentField: .password
            )
            .padding(.bottom)
            Button("로그인") {
                viewModel.action(.logunButtonTapped)
            }
            .padding()
            .appFont(PaperlogyFontStyle.caption, textColor: .grayScale0)
            .frame(maxWidth: .infinity)
            .background(.blackSeafoam)
            .cornerRadius(15)
            
            Spacer()
                 
            HStack() {
                Spacer()
                Button {
                    withAnimation(.easeInOut) {
                        selectedIndex = 1
                    }
                } label: {
                    Text("지금 가입하세요 >")
                        .appFont(PaperlogyFontStyle.caption, textColor: .grayScale75)
                }
                .padding(.bottom, 20)
                .padding(.trailing)
                
            }
            .ignoresSafeArea(.keyboard)
            
        }
      
        .onLoginSuccessModify(coordinator, viewModel.output.loginSuccessed)
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
            title: viewModel.output.loginError?.title,
            message: viewModel.output.loginError?.message
        )
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = nil
        }
           
    }
    
}


// MARK: Floating TextField
extension EmailLoginView {
    
    private struct FloatingLabelTextField: View {
        let title: String
        @Binding var text: String
        var isFocused: FocusState<LoginInputFieldType?>.Binding
        var currentField: LoginInputFieldType

        var body: some View {
            ZStack(alignment: .leading) {
                // 밑줄
                VStack {
                    Spacer()
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(isFocused.wrappedValue == currentField ? .blue : .gray)
                }
                
                // 텍스트필드와 플로팅 레이블
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .appFont(
                            isFocused.wrappedValue == currentField ? PretendardFontStyle.body3 : PretendardFontStyle.body1,
                            textColor: isFocused.wrappedValue == currentField ? .deepSeafoam : .grayScale60
                        )
                        .offset(y: isFocused.wrappedValue == currentField || !text.isEmpty ? -10 : 20)
                        .animation(.spring(response: 0.4), value: isFocused.wrappedValue == currentField || !text.isEmpty)
                    
                    TextField("", text: $text)
                        .focused(isFocused, equals: currentField)
                        .frame(height: 30)
                }
                .padding(.top, 15)
            }
            .frame(height: 40)
        }
    }

    private struct FloatingLabelSecureField: View {
        let title: String
        @Binding var text: String
        var isFocused: FocusState<LoginInputFieldType?>.Binding
        var currentField: LoginInputFieldType
        @State private var isTextVisible: Bool = false

        var body: some View {
            ZStack(alignment: .leading) {
                VStack {
                    Spacer()
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(isFocused.wrappedValue == currentField ? .blue : .gray)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .appFont(
                            isFocused.wrappedValue == currentField ? PretendardFontStyle.body3 : PretendardFontStyle.body1,
                            textColor: isFocused.wrappedValue == currentField ? .deepSeafoam : .grayScale60
                        )
                        .offset(y: isFocused.wrappedValue == currentField || !text.isEmpty ? -10 : 20)
                        .animation(.spring(response: 0.4), value: isFocused.wrappedValue == currentField || !text.isEmpty)
                    
                    HStack {
                        Group {
                            if isTextVisible {
                                TextField("", text: $text)
                                    .focused(isFocused, equals: currentField)
                            } else {
                                SecureField("", text: $text)
                                    .focused(isFocused, equals: currentField)
                            }
                        }
                        
                        
                        Button(action: {
                            isTextVisible.toggle()
                        }) {
                            Image(systemName: isTextVisible ? "eye" : "eye.slash")
                                .foregroundColor(.grayScale60)
                        }
                    }
                    .frame(height: 30)
                }
                .padding(.top, 15)
            }
            .frame(height: 40)
        }
    }


}


#Preview {
    //PreViewHelper.makeEmailLoginView()
}

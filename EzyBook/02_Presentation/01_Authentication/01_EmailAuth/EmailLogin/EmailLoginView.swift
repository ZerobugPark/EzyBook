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

    private let coordinator: AuthCoordinator
    @FocusState private var isFocused: LoginInputFieldType?
    
    init(selectedIndex: Binding<Int>, viewModel: EmailLoginViewModel, coordinator: AuthCoordinator) {
        _selectedIndex = selectedIndex
        self.viewModel = viewModel
        self.coordinator = coordinator
    }
    
    

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
        .padding(.horizontal)
        .onLoginSuccessModify(coordinator, viewModel.output.loginSuccessed)
        .commonAlert(
            isPresented: Binding(
                get: { viewModel.output.isShowingError },
                set: { isPresented in
                    if !isPresented {
                        viewModel.action(.resetError)
                        isFocused = nil
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
        .onChange(of: viewModel.output.loginSuccessed) { success in
            if success {
                isFocused = nil
            }
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
                        .scaleEffect(isFocused.wrappedValue == currentField || !text.isEmpty ? 0.9 : 1.0, anchor: .leading)
                        .offset(y: isFocused.wrappedValue == currentField || !text.isEmpty ? 0 : 20)
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
                        .scaleEffect(isFocused.wrappedValue == currentField || !text.isEmpty ? 0.9 : 1.0, anchor: .leading)
                        .offset(y: isFocused.wrappedValue == currentField || !text.isEmpty ? 0 : 20)
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

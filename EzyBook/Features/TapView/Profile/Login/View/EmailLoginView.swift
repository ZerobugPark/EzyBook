//
//  EmailLoginView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/17/25.
//

import SwiftUI

struct EmailLoginView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @Binding var selectedIndex: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            FloatingLabelTextField(title: "이메일", text: $email)
            FloatingLabelSecureField(title: "비밀번호", text: $password)
                .padding(.bottom)
            Button("로그인") {
                // 로그인 처리
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
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
                }
                .padding(.trailing)
            }

            
        }   .padding(.horizontal)
    }
    
}

#Preview {
    PreViewHelper.makeEmailLoginView()
}

struct FloatingLabelTextField: View {
    let title: String
    @Binding var text: String
    var isSecure: Bool = false
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            // 밑줄
            VStack {
                Spacer()
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(isFocused ? .blue : .gray)
            }
            
            // 텍스트필드와 플로팅 레이블
            VStack(alignment: .leading, spacing: 0) {
                // 플로팅 레이블
                Text(title)
                    .font(.system(size: isFocused || !text.isEmpty ? 12 : 16))
                    .foregroundColor(isFocused ? .blue : .gray)
                    .offset(y: isFocused || !text.isEmpty ? -10 : 20)
                    .animation(.spring(response: 0.2), value: isFocused || !text.isEmpty)
                
                // 텍스트필드
                Group {
                    if isSecure {
                        SecureField("", text: $text)
                            .focused($isFocused)
                    } else {
                        TextField("", text: $text)
                            .focused($isFocused)
                    }
                }
                .frame(height: 30)
            }
            .padding(.top, 15) // 레이블이 위로 올라갈 공간 확보
        }
        .frame(height: 40)
        .onChange(of: isFocused) { newValue in
            print("포커스 상태 변경: \(newValue)")
        }
    }
}


struct FloatingLabelSecureField: View {
    let title: String
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    @State private var isTextVisible: Bool = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                Spacer()
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(isFocused ? .blue : .gray)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: isFocused || !text.isEmpty ? 12 : 16))
                    .foregroundColor(isFocused ? .blue : .gray)
                    .offset(y: isFocused || !text.isEmpty ? -10 : 20)
                    .animation(.spring(response: 0.2), value: isFocused || !text.isEmpty)
                
                HStack {
                    Group {
                        if isTextVisible {
                            TextField("", text: $text)
                        } else {
                            SecureField("", text: $text)
                        }
                    }
                    .focused($isFocused)
                    
                    Button(action: {
                        isTextVisible.toggle()
                    }) {
                        Image(systemName: isTextVisible ? "eye" : "eye.slash")
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: 30)
            }
            .padding(.top, 15)
        }
        .frame(height: 40)
    }
}

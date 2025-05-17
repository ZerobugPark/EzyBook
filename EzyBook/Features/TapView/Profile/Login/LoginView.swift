//
//  LoginView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI

struct LoginView: View {
    
    @Binding var showModal: Bool
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                // 뒤로가기 버튼
                
                HStack(alignment: .center) {
                    Button {
                        showModal = false
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }.padding()
                
                
                VStack(alignment: .center) {
                    
                    Text("로그인을 통해, 지금 여행을 계획해보세요")
                        .font(.title)
                        .padding()
                    joinEmalil
                    appleLogin
                    kakaoLogin
                    
                
                    createAccount
                    Spacer()
                    
                    
                }
                .frame(maxWidth: .infinity, alignment: .center)  // 텍스트는 중앙 정렬
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }
    
    
    private var createAccount: some View {
        NavigationLink {
            let viewModel = container.makeAccountViewModel()
            CreateAccountView(viewModel: viewModel)
        } label: {
            Text("회원이 아니신가요?")  // 버튼 텍스트
                .font(.caption)  // 텍스트 폰트
                .foregroundColor(.grayScale90)  // 텍스트 색상
                .padding()  // 텍스트 주변 여백
        }
    }
    
    
    private var joinEmalil: some View {
        NavigationLink {
            
        } label: {
            Text("Continue with Email")
                .font(.headline)
                .foregroundColor(.black)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.black, lineWidth: 1)
                )
                .padding(.horizontal, 43)
        }
    }
    
    private var appleLogin: some View {
        Button {
            
        } label: {
            Image(.appleLogin)
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
            
        }
        
    }
    
    private var kakaoLogin: some View {
        Button {
            
        } label: {
            Image(.kakaoLogin)
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 43)
        }
    }
    
}


#Preview {
    PreViewHelper.makeLoginView()
}

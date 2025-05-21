//
//  LoginView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    
    

    @StateObject var viewModel: LoginViewModel
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading,spacing: 10) {
                content
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }
    
//    private var backButton: some View {
//        HStack {
//            Button {
//                showModal = false
//            } label: {
//                Image(systemName: "chevron.left")
//                    .foregroundColor(.blue)
//            }
//            Spacer()
//        }
//        .padding()
//    }
    
    private var content: some View {
        VStack(alignment: .center) {
            Text("로그인을 통해, 지금 여행을 계획해보세요")
                .font(.title)
                .padding()
            
            joinEmail
            appleLogin
            kakaoLogin
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var joinEmail: some View {
        NavigationLink {
            LoginSignUpPagerView()
        } label: {
            Text("Continue with Email")
                .font(.headline)
                .foregroundColor(.black)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(Color.black, lineWidth: 1)
                )
                .padding(.horizontal, 43)
        }
    }
    
    private var appleLogin: some View {
        SignInWithAppleButton(.signIn, onRequest: { request in
            viewModel.action(.appleLoginButtonTapped(reqeust: request))
        }, onCompletion: { result in
            viewModel.action(.appleLoginCompleted(result: result))
        })
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 43)
        
    }
    
    private var kakaoLogin: some View {
        Button {
            viewModel.action(.kakaoLoginButtonTapped)
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

extension LoginView {
    
    // MARK: Layout Constants
    private enum Layout {
        static let horizontalPadding: CGFloat = 43
        static let buttonHeight: CGFloat = 50
        static let iconPaddingHorizontal: CGFloat = 30
    }

}

#Preview {
    PreViewHelper.makeLoginView()
}

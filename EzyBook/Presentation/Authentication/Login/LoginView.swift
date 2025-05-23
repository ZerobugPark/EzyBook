//
//  LoginView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    
    @EnvironmentObject var authModel: AuthModelObject
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
    }
    

    private var content: some View {
        VStack(alignment: .center) {
            Text("로그인을 통해, 지금 여행을 계획해보세요")
                .appFont(PaperlogyFontStyle.title)
                .foregroundStyle(.grayScale90)
                .padding()
            
            joinEmail
            appleLogin
            kakaoLogin
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var joinEmail: some View {
        Button {
            authModel.push(.emailLogin)
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
        .onLoginSuccessModify(viewModel.output.loginSuccessed)
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
        .onLoginSuccessModify(viewModel.output.loginSuccessed)
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

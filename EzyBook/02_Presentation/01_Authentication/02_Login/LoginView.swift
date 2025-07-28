//
//  LoginView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    
    @ObservedObject var coordinator: AuthCoordinator
    @StateObject var viewModel: LoginViewModel
    
    var body: some View {
        
        VStack(alignment: .leading,spacing: 0) {
            content
                .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onLoginSuccessModify(coordinator, viewModel.output.loginSuccessed)
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
        VStack(alignment: .center, spacing: 10) {
            LoginAnimation(animationName: "LoginAnimation")
                .frame(width: 250, height: 250)
                .padding(.top, 50)
            Text("이지북으로 예약하고,\n간편하게 예약 하세요!")
                .appFont(PaperlogyFontStyle.title, textColor: .blackSeafoam)
                .padding(.top, 30)
            
            Spacer()
            joinEmail
            appleLogin
            kakaoLogin

        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var joinEmail: some View {
        Button {
            coordinator.push(.emailLogin)
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

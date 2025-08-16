//
//  LoginSignUpPagerView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/18/25.
//

import SwiftUI

struct LoginSignUpPagerView: View {
    @State private var selectedIndex = 0
    @State private var bounce = false
    
    private let coordinator: AuthCoordinator
    @ObservedObject private var loginViewModel: EmailLoginViewModel
    @ObservedObject private var accountViewModel: CreateAccountViewModel
    
    init(coordinator: AuthCoordinator, loginViewModel: EmailLoginViewModel, accountViewModel: CreateAccountViewModel) {

        self.coordinator = coordinator
        self.loginViewModel = loginViewModel
        self.accountViewModel = accountViewModel
    }
    
    private let titles = ["로그인", "회원가입"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            BackButtonView {
                coordinator.pop()
            }
            .padding(.leading, 5)
            .padding(.top, 10)
            
            Text(titles[selectedIndex])
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: selectedIndex == 0 ? .leading : .trailing)
                .animation(.easeInOut(duration: 0.4), value: selectedIndex)
                .padding(.horizontal)
                
            
            TabView(selection: $selectedIndex) {
                EmailLoginView(
                    selectedIndex: $selectedIndex,
                    viewModel: loginViewModel,
                    coordinator: coordinator
                )
                    .padding(.top, 10)
                    .tag(0)
                CreateAccountView(
                    selectedIndex: $selectedIndex,
                    viewModel: accountViewModel
                )
                    .padding(.top, 10)
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            Spacer()
        }
        .navigationBarHidden(true)
    }
    
    private func triggerBounce() {
           bounce = false
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { // 이동 후 bounce
               bounce = true
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                   bounce = false // 원상 복구
               }
           }
       }
}

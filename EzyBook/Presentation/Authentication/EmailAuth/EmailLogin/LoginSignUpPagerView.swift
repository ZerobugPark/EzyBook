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
    
    @EnvironmentObject var authModel: AuthModelObject
    @EnvironmentObject private var container: DIContainer
    
    private let titles = ["로그인", "회원가입"]
    
    var body: some View {
        VStack(spacing: 10) {
            backButton
            Text(titles[selectedIndex])
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: selectedIndex == 0 ? .leading : .trailing)
                .animation(.easeInOut(duration: 0.4), value: selectedIndex)
                .padding(.horizontal)
                
            
            TabView(selection: $selectedIndex) {
                EmailLoginView(selectedIndex: $selectedIndex, viewModel: container.makeEmailLoginViewModel())
                    .padding(.top, 10)
                    .tag(0)
                CreateAccountView(selectedIndex: $selectedIndex, viewModel: container.makeAccountViewModel())
                    .padding(.top, 10)
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            Spacer()
        }
        .navigationBarHidden(true)
    }
    
    private var backButton: some View {
        HStack {
            Button {
                authModel.pop()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.blue)
            }
            Spacer()
        }
        .padding()
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

#Preview {
    PreViewHelper.makeLoginSignUpPagerView()
}

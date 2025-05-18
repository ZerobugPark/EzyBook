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
            VStack(alignment: .leading,spacing: 10) {
                backButton
                content
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }
    
    private var backButton: some View {
        HStack {
            Button {
                showModal = false
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
            }
            Spacer()
        }
        .padding()
    }
    
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
            container.kakaoLoginUseCase()
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

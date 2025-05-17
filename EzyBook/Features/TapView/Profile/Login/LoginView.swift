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
    
    
    
    
    
}


#Preview {
    PreViewHelper.makeLoginView()
}

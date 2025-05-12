//
//  ProfileView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI

struct ProfileView: View {
    
    @State private var showModal = false
    
    
    var body: some View {
        VStack {
             Button {
                 showModal = true
             } label: {
                 Text("로그인 테스트")
                     .padding()
                     .background(Color.blue)
                     .foregroundColor(.white)
                     .cornerRadius(8)
             }
            
            Button {
                test()
            } label: {
                Text("네트워크 테스트")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
         }
         .fullScreenCover(isPresented: $showModal) {
             LoginView(showModal: $showModal)
         }
    }
    private func test() {
        NetworkService.shared.request(data: EmailValidationResponseDTO.self,  UserRequest.emailLogin(body: EmailLoginRequestDTO(email: "123", password: "123", deviceToken: nil)))
    }
}

#Preview {
    ProfileView()
}

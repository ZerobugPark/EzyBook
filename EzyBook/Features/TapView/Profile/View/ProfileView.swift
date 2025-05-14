//
//  ProfileView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI

struct ProfileView: View {
    
    @State private var showModal = false
    @EnvironmentObject var container: DIContainer
    
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
        
        let requestDTO = EmailValidationRequestDTO(email: "sesddddac_re_jack@gmail.com")
        let networkRepository = container.makeNetworkRepository()
        networkRepository.fetchData(UserRequest.emailValidation(body: requestDTO)) { (result: Result<EmailValidationResponseDTO, APIErrorResponse>) in
            
            switch result {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
        
     
    }
}

#Preview {
    ProfileView()
}

//
//  HomeView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/24/25.
//

import SwiftUI

struct HomeView: View {
    
    //private let test = DefaultNetworkService(decodingService: ResponseDecoder())
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        VStack {
            Button {
                networkTest()
            } label: {
                Text("통신 테스트")
            }
            
            Button {
                networkTest2()
            } label: {
                Text("통신 테스트2")
            }
        }
        
        
    }
    
    func networkTest() {
       
        let data = ActivitySummaryListRequestDTO(country: "대한민국", category: nil, limit: "5", next: nil)
        
        container.activityListUseCase.execute(requestDto: data) { result in
            switch result {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func networkTest2() {
       
        container.activityNewListUseCase.execute(country: "일본", category: nil) { result in
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
    HomeView()
}

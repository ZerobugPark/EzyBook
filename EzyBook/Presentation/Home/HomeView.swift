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
                networkTest3()
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
       
        let data = ActivitySummaryListRequestDTO(country: "대한민국", category: "투어", limit: "5", next: nil)
        
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
       
        container.activityNewListUseCase.execute(country: "일본", category: "투어") { result in
            switch result {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    //액티비티 검색
    func networkTest3() {
       
        
        container.activitySearchUseCase.execute(title: "스키")  { result in
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

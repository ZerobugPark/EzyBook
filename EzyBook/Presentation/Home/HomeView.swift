//
//  HomeView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/24/25.
//

import SwiftUI

struct HomeView: View {
    
    private let test = DefaultNetworkService(decodingService: ResponseDecoder())
    
    var body: some View {
        VStack {
            Button {
                networkTest()
            } label: {
                Text("통신 테스트")
            }
        }
    }
    
    func networkTest() {
        let storage  = KeyChainTokenStorage()
        let key = storage.loadToken(key: KeychainKeys.accessToken)!
        
        /// 목록조회 OK
        //let router = ActivityRequest.activityFiles(accessToken: key)
        
        // 상세조회 오류
        //let router = ActivityRequest.activityDetail(accessToken: key, id: "f4df4b150d87cc76f2")
        
        // 신규 액티비티 조회
        //let router = ActivityRequest.newActivities(accessToken: key)
        
        let router = UserGetRequest.profileLookUp(accessToken: key)
        
        Task {
            do {
                let data = try await test.fetchData(dto: ProfileLookUpResponseDTO.self, router)
                print(data)
            } catch {
                print(error)
            }
    
        }
        
    }
}

#Preview {
    HomeView()
}

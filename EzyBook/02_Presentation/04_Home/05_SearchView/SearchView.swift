//
//  SearchView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/31/25.
//

import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var appState: AppState
    
    @StateObject var viewModel: SearchViewModel
    @StateObject var bannerViewModel: BannerViewModel
    @ObservedObject var coordinator: HomeCoordinator
   
    @State private var isSearching = false
    @State private var isBanner = false
    @State private var bannerMessage = ""
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 15) {
                    makeAdvertiseView()
                    ActivityIntroduceView(data: viewModel.output.activitySearchDetailList) { index in
                        viewModel.action(.keepButtonTapped(index: index))
                    } currentIndex: { index in
                        viewModel.action(.prefetchSearchContent(index: index))
                    } onItemTapped: { id in
                        coordinator.push(.detailView(activityID: id))
                    }
                    
                }
            }
            .disabled(viewModel.output.isLoading)
            
            LoadingOverlayView(isLoading: viewModel.output.isLoading)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButtonView {
                    coordinator.pop()
                }
            }
            ToolbarItem(placement: .principal) {
                Text("EXCITING")
                    .appFont(PaperlogyFontStyle.body, textColor: .blackSeafoam)
            }
        }
        .contentShape(Rectangle()) // 전체 터치 가능하게 (키보드 내리기 위해서)
        .onTapGesture {
            hideKeyboard()
            isSearching = false
        }
        .searchModify($viewModel.input.query, $isSearching)
        .onSubmit(of: .search, {
            viewModel.action(.searchButtonTapped)
            isSearching = false
        })
        .withCommonUIHandling(viewModel) { code in
            if code == 418 {
                appState.isLoggedIn = false
            }
        }
        .commonAlert(
            isPresented: $isBanner,
            title: "안내",
            message: bannerMessage
        )
        .onAppear {
            // 탭바 터치 가능 여부
            appState.isLoding = viewModel.output.isLoading
            
        }
        .loadingOverlayModify(viewModel.output.isLoading)
        
    }
    


}



// MARK: 광고 영역
extension SearchView {
    
    private func makeAdvertiseView() -> some View {
        ZStack {
            BannerView(viewModel: bannerViewModel) { _ in
                coordinator.pushAdvertiseView { result in
                    
                    self.bannerMessage = "\(result)번째 출석이 완료되었습니다."
                    self.isBanner = true
                    
                }
            }
        }
    }

}




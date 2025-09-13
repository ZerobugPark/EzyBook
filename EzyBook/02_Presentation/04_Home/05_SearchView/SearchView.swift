//
//  SearchView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/31/25.
//

import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var appState: AppState
    
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var bannerViewModel: BannerViewModel
    private let coordinator: HomeCoordinator
   
    @State private var isSearching = false
    
    
    init(viewModel: SearchViewModel, bannerViewModel: BannerViewModel, coordinator: HomeCoordinator) {
        self.viewModel = viewModel
        self.bannerViewModel = bannerViewModel
        self.coordinator = coordinator
    }
    
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 15) {
                    makeAdvertiseView()
                    ActivityIntroduceView(data: viewModel.output.activitySearchDetailList)  { index in
                        viewModel.action(.prefetchSearchContent(index: index))
                    } onItemTapped: { [weak coordinator] id in
                        coordinator?.push(.detailView(activityID: id))
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
                Text("검색")
                    .appFont(PaperlogyFontStyle.body, textColor: .blackSeafoam)
            }
        }
        .contentShape(Rectangle()) // 전체 터치 가능하게 (키보드 내리기 위해서)
        .onTapGesture {
            hideKeyboard()
            isSearching = false
        }
        .searchModify($viewModel.input.query, $isSearching, "국가 또는 투어를 입력해주세요.")
        .onSubmit(of: .search, {
            viewModel.action(.searchButtonTapped)
            isSearching = false
        })
        .withCommonUIHandling(viewModel) { code, _ in
            if code == 418 {
                appState.isLoggedIn = false
            }
        }
        
    }
    
}



// MARK: 광고 영역
extension SearchView {
    
    private func makeAdvertiseView() -> some View {
        ZStack {
            BannerView(viewModel: bannerViewModel) { [weak coordinator] _ in
                coordinator?.pushAdvertiseView { result in
                    viewModel.action(.bannerResult(msg: result))
                
                }
            }
        }
    }

}




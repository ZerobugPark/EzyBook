//
//  SearchView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/31/25.
//

import SwiftUI

struct SearchView: View {
    
    @Environment(\.displayScale) var scale
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
                   // makeRecommendView()
                    ActivityIntroduceView(data: $viewModel.output.activitySearchDetailList) { index in
                        viewModel.action(.keepButtonTapped(index: index))
                    } currentIndex: { index in
                        viewModel.action(.prefetchSearchContent(index: index))
                    } onItemTapped: { id in
                        print("TODO: DetailView ")
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
        .contentShape(Rectangle()) // 전체 터치 가능하게
        .onTapGesture {
            hideKeyboard()
            isSearching = false
        }
        .searchModify($viewModel.input.query, $isSearching)
        .onSubmit(of: .search, {
            viewModel.action(.searchButtonTapped)
            isSearching = false
        })
        .commonAlert(
            isPresented: Binding(
                get: { viewModel.output.isShowingError },
                set: { isPresented in
                    if !isPresented {
                        viewModel.action(.resetError)
                    }
                }
            ),
            title: viewModel.output.presentedError?.message.title,
            message: viewModel.output.presentedError?.message.msg
        )
        .commonAlert(
            isPresented: $isBanner,
            title: "안내",
            message: bannerMessage
        )
   
        .onAppear {
            // 탭바 터치 가능 여뷰
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

// MARK: 추천 영역
extension SearchView {
    
    private func makeRecommendView() -> some View {
        ZStack {
            Rectangle()
                .fill(.blackSeafoam) // 원하는 색상으로 설정
                .frame(maxWidth: .infinity)
                .frame(height: 150)
            
            Text("추천뷰입니다.")
        }
        
    }

}



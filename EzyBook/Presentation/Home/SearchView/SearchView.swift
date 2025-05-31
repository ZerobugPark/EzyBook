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
    @ObservedObject var coordinator: HomeCoordinator
   
    @State private var isSearching = false
    
    var body: some View {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 10) {
                    makeAdvertiseView()
                    makeRecommendView()
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                           backButton
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
                .onAppear {
                    appState.isLoding = viewModel.output.isLoading
                }
                .loadingOverlayModify(viewModel.output.isLoading)

            }
            
    }
    
    private var backButton: some View {
        HStack() {
            Button {
                coordinator.pop()
            } label: {
                Image(.iconChevron)
                    .renderingMode(.template)
                    .foregroundStyle(.blackSeafoam)
                    
            }
            Spacer()
        }
    }
}


// MARK: 광고 영역
extension SearchView {
    
    private func makeAdvertiseView() -> some View {
        ZStack {
            Rectangle()
                .fill(.deepSeafoam) // 원하는 색상으로 설정
                .frame(maxWidth: .infinity)
                .frame(height: 150)
            
            Text("광고뷰 입니다.")
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



//#Preview {
//    PreViewHelper.makeSearchView()
//}

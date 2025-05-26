//
//  HomeView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/24/25.
//

import SwiftUI

struct HomeView: View {
    
    @State private var selectedFlag: Flag = .all
    @State private var selectedFilter: Filter = .all
    
    @StateObject var viewModel: HomeViewModel
    @State var searchText = ""
    
    private let array = ["1", "2", "3"]
    
    /// 버튼 컬럼
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
    
    /// 버튼 Rows
    private let rows = [GridItem(.flexible(), spacing: 20)]
    
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 15) {
                
                if viewModel.output.isLoading {
                    ProgressView()
                } else {
                    
                    makeSearchBarButton()
                    
                    BasicCarousel(pageCount: array.count, visibleEdgeSpace: 20, spacing: 10) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue)
                                .shadow(radius: 5)
                            Text(array[index])
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: 200)
                    
                    
                    makeFlagSelectionView()
                    makeFilterSelectionView()
                    
                    
                }
                
            }
            .onAppear {
                //viewModel.action(.onAppearRequested)
            }
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
        }
    }
    
}

#Preview {
    PreViewHelper.makeHomeView()
}


// MARK: flage Button
extension HomeView {
    
    private func makeFlagSelectionView() -> some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(Flag.allCases) { flag in
                makeFlagButton(flag)
            }
        }
        .padding(.horizontal, 10)
    }
    
    private func makeFlagButton(_ flag: Flag) -> some View {
        Button {
            selectedFlag = flag
            viewModel.action(.selectionChanged(flag: selectedFlag, filter: selectedFilter))
        } label: {
            VStack(alignment: .center, spacing: 0) {
                flag.image
                    .resizable()
                    .frame(width: 50, height: 50)
                if flag != .all {
                    Text(flag.rawValue)
                        .appFont(PretendardFontStyle.caption1)
                        .foregroundStyle(selectedFlag == flag ? .blackSeafoam : .grayScale100)
                }
                
            }
            .frame(width: 70, height: 75)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedFlag == flag ? .deepSeafoam.opacity(0.3) : Color.white)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.grayScale60, lineWidth: 0.5)
            }
        }
    }
    
}


// MARK: Filter Button
extension HomeView {
    
    private func makeFilterSelectionView() -> some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows) {
                ForEach(Filter.allCases) { filter in
                    makeFilterButton(filter)
                }
            }
            .padding(.horizontal, 10)
        }
        .scrollIndicators(.hidden)
    }
    
    private func makeFilterButton(_ filter: Filter) -> some View {
        Button {
            selectedFilter = filter
            viewModel.action(.selectionChanged(flag: selectedFlag, filter: selectedFilter))
        } label: {
            Text(filter.rawValue)
                .appFont(PretendardFontStyle.caption1)
                .foregroundStyle(selectedFilter == filter ? .blackSeafoam : .grayScale100)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 17)
                        .fill(selectedFilter == filter ? .deepSeafoam.opacity(0.3) : Color.white)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 17)
                        .stroke(.grayScale60, lineWidth: 0.5)
                }
            
        }
    }
}

// MARK: Custom SearchBar

extension HomeView {
    private func makeSearchBarButton() -> some View {
        Button {
            //viewModel.action(.searchTapped)
        } label: {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blackSeafoam)
                Text("찾으시는 액티비티가 있나요?")
                    .appFont(PretendardFontStyle.body1)
                    .foregroundColor(.grayScale75)
                Spacer()
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.grayScale30))
            )
        }
        .padding(.horizontal, 10)
        .padding(.top, 30)
        
    }
    
    
}


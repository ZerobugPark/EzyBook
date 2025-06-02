//
//  HomeView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/24/25.
//

import SwiftUI

struct HomeView: View {
    
    @Environment(\.displayScale) var scale
    
    @EnvironmentObject var appState: AppState
    
    @State private var selectedFlag: Flag = .all
    @State private var selectedFilter: Filter = .all
    @StateObject var viewModel: HomeViewModel
    
    @ObservedObject var coordinator: HomeCoordinator
    
    /// 버튼 컬럼
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
    
    /// 버튼 Rows
    private let rows = [GridItem(.flexible(), spacing: 20)]
    
    var title: some View {
        Text("EzyBook")
            .appFont(PaperlogyFontStyle.body, textColor: .blackSeafoam)
    }
    
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                VStack(alignment: .center, spacing: 15) {
                    
                    makeSearchBarButton()
                    makeNewActivityView()
                    makeFlagSelectionView()
                    makeFilterSelectionView()
                    ActivityIntroduceView(data: $viewModel.output.filterActivityDetailList) { index in
                        viewModel.action(.keepButtonTapped(index: index))
                    } currentIndex: { index in
                        viewModel.action(.prefetchfilterActivityContent(index: index))
                        viewModel.action(.paginationAcitiviyList(flag: selectedFlag, filter: selectedFilter, index: index))
                    } onItemTapped: { id in
                        coordinator.push(.detailView(activityID: id))
                    }
             
                }
            }
            .scrollIndicators(.hidden)
            .disabled(viewModel.output.isLoading)
            
            if viewModel.output.isLoading {
                Color.white.opacity(0.3)
                    .ignoresSafeArea(edges: .all)
                    .overlay(
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .grayScale100))
                    )
                    .transition(.opacity)
                    .animation(.easeInOut, value: viewModel.output.isLoading)
            }
          
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                title
            }

            ToolbarItem(placement: .topBarTrailing) {
                HStack(alignment: .center, spacing: 0) {
                    makeAlarmButton()
                    makeKeppButton()
                }
            }
            
        }
        .onAppear {
            viewModel.action(.onAppearRequested(flag: selectedFlag, filter: selectedFilter))
            viewModel.action(.updateScale(scale: scale))
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
        .onAppear {
            appState.isLoding = viewModel.output.isLoading
        }
        .loadingOverlayModify(viewModel.output.isLoading)
    }
    
}

#Preview {
    //PreViewHelper.makeHomeView()
}

// MARK: Custom SearchBar
extension HomeView {
    private func makeSearchBarButton() -> some View {
        Button {
            coordinator.push(.searchView)
        } label: {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blackSeafoam)
                Text("찾으시는 액티비티가 있나요?")
                    .appFont(PretendardFontStyle.body1, textColor: .grayScale75)
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

// MARK: New Activity
extension HomeView {
    
    @ViewBuilder
    private func makeNewActivityView() -> some View {
        makeNewActivityTitle()
        makeCarouselImageView()
        
    }
    
    private func makeNewActivityTitle() -> some View {
        HStack {
            Text("NEW 액티비티")
                .appFont(PaperlogyFontStyle.caption)
            Spacer()
        }.padding(.horizontal, 10)
    }
    
    
    private func makeCarouselImageView() -> some View {
        BasicCarousel(pageCount: viewModel.output.activityNewDetailList.count, visibleEdgeSpace: 40, spacing: 10,  onPageChanged: { currentIndex in
            viewModel.action(.prefetchNewContent(index: currentIndex))
        }
        ) { index in
            GeometryReader { geo in
                ZStack(alignment: .bottomLeading) {
                    
                    Image(uiImage: viewModel.output.activityNewDetailList[index].thumnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    
                    makeNewActivityTags(data: viewModel.output.activityNewDetailList[index])
                    
                }
                .cornerRadius(15)
                .shadow(radius: 2)
            }
        }
        .frame(height: 300)
    }
    
    private func makeNewActivityTags(data:  NewActivityModel) -> some View {
        
        VStack {
            VStack(spacing: 10) {
                HStack(alignment: .center) {
                    LocationTagView(country: data.country)
                    Spacer()
                }
                Spacer()
            }.padding(10)
            
            
            VStack(alignment: .leading, spacing: 10) {
                Text(data.title)
                    .appFont(PaperlogyFontStyle.title, textColor: .grayScale0)
                    .shadow(color: .black.opacity(0.6), radius: 2)
                
                Label {
                    Text("\(data.originalPrice)")
                        .appFont(PaperlogyFontStyle.caption, textColor: .grayScale0)
                        .shadow(color: .black.opacity(0.6), radius: 2)
                } icon: {
                    Image(.iconWon)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.grayScale0)
                }
                
                Text(data.description)
                    .appFont(PretendardFontStyle.caption1, textColor: .grayScale30)
                    .lineSpacing(4)
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                
                
                
            }
            .padding()
        }
        
    }
    
}


// MARK: Flag Button
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
                        .appFont(PretendardFontStyle.caption1, textColor: selectedFlag == flag ? .blackSeafoam : .grayScale100)
                }
                
            }
            .frame(width: 70, height: 75)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedFlag == flag ? .deepSeafoam.opacity(0.3) : Color.white)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.grayScale60, lineWidth: 0.2)
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
                .appFont(PretendardFontStyle.caption1, textColor: selectedFilter == filter ? .blackSeafoam : .grayScale100)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 17)
                        .fill(selectedFilter == filter ? .deepSeafoam.opacity(0.3) : Color.white)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 17)
                        .stroke(.grayScale60, lineWidth: 0.2)
                }
            
        }
    }
}

// MARK: 내용입력

extension HomeView {
    
    private func makeAlarmButton() -> some View {
        Button {
            print("text heart")
        } label: {
            Image(.iconNoti)
        }
    }
    
    private func makeKeppButton() -> some View {
        
        Button {
            print("test heart")
        } label: {
            Image(.iconLikeEmpty)
        }

    }
}


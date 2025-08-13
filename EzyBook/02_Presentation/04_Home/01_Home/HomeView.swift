//
//  HomeView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/24/25.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var appState: AppState
    
    private let coordinator: HomeCoordinator
    @ObservedObject var viewModel: HomeViewModel
    
    init(coordinator: HomeCoordinator, viewModel: HomeViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
    }
    
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 15) {
                    
                    makeSearchBarButton()
                    NewActivityView(
                        activities: viewModel.output.activityNewDetailList) { index in
                            viewModel.action(.prefetchNewContent(index: index))
                        } onItemTapped: { id in
                            coordinator.push(.detailView(activityID: id))
                        }

                    FlagSelectionView(
                        selectedFlag: $viewModel.selectedFlag) { flag in
                            viewModel.action(.selectionChanged(flag: flag, filter: viewModel.selectedFilter))
                        }
                    
                    FilterSelectionView(
                        selectedFilter: $viewModel.selectedFilter) { filter in
                            viewModel.action(.selectionChanged(flag: viewModel.selectedFlag, filter: filter))
                        }
      
                    ActivityIntroduceView(data: viewModel.output.filterActivityDetailList) { index in
                        viewModel.action(.prefetchfilterActivityContent(index: index))
                        viewModel.action(.paginationAcitiviyList(index: index))
                    } onItemTapped: { id in
                        coordinator.push(.detailView(activityID: id))
                    }
             
                }
            }
            .disabled(viewModel.output.isLoading)
            
            LoadingOverlayView(isLoading: viewModel.output.isLoading)
        
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                TitleTextView(title: "EzyBook")
            }

            ToolbarItem(placement: .topBarTrailing) {
                HStack(alignment: .center, spacing: 0) {
                    makeAlarmButton()
                }
            }
            
        }
        .withCommonUIHandling(viewModel) { code, _ in
            if code == 418 {
                appState.isLoggedIn = false
            }
        }
        .loadingOverlayModify(viewModel.output.isLoading)
        
        
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
    
}



// MARK: Component

//컴포넌트(struct)로 분리할지 여부는 재사용성보다 “UI 복잡도와 반복성”이 기준

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
    
    private struct NewActivityView: View {
        
        let activities: [NewActivityModel]
        let onPageChanged: (Int) -> Void
        let onItemTapped: (String) -> Void
        
        var body: some View {
            VStack {
                makeTitle()
                makeCarousel()
            }
            
        }
        
        private func makeTitle() -> some View {
            HStack {
                Text("NEW 액티비티")
                    .appFont(PaperlogyFontStyle.caption)
                Spacer()
            }.padding(.horizontal, 10)

        }
        
        private func makeCarousel() -> some View {
            BasicCarousel(pageCount: activities.count, visibleEdgeSpace: 40, spacing: 10,  onPageChanged: onPageChanged) { index in
                GeometryReader { geo in
                    ZStack(alignment: .bottomLeading) {
               
                        RemoteImageView(path: activities[index].thumnail)
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                        
                        makeTags(data: activities[index])
                        
                    }
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    .onTapGesture {
                        onItemTapped(activities[index].activityID)
                    
                    }
                }
            }
            .frame(height: 300)
            
        }
        
        private func makeTags(data:  NewActivityModel) -> some View {
            
            VStack(alignment: .leading) {
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
                        Text("\(data.finalPrice)")
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
    
}


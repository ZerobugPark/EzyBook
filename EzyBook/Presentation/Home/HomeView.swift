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
    
    @Environment(\.displayScale) var scale
    
    /// 버튼 컬럼
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
    
    /// 버튼 Rows
    private let rows = [GridItem(.flexible(), spacing: 20)]
    
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .center, spacing: 15) {
                
//                makeSearchBarButton()
//                makeNewActivityView()
//                makeFlagSelectionView()
//                makeFilterSelectionView()
//                makeFilterResultView()
                
                
                /// 추천은 고민좀 해보자.
                
                                if viewModel.output.isLoading {
                                    ProgressView()
                                } else {                
                                    makeSearchBarButton()
                                    makeNewActivityView()
                                    makeFlagSelectionView()
                                    makeFilterSelectionView()
                                    makeFilterResultView()
                                }
                
            }
            .onAppear {
                viewModel.action(.updateScale(scale: scale))
                viewModel.action(.onAppearRequested)
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
            
            Button {
                
            } label: {
                Text("View")
                    .appFont(PretendardFontStyle.body1, textColor: .deepSeafoam)
            }
        }.padding(.horizontal, 10)
    }
    
    
    private func makeCarouselImageView() -> some View {
        BasicCarousel(pageCount: viewModel.output.activityNewDetailList.count, visibleEdgeSpace: 40, spacing: 10) { index in
            GeometryReader { geo in
                ZStack(alignment: .bottomLeading) {
                    
                    Image(uiImage: viewModel.output.activityNewDetailList[index].thumnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    
                    
                    VStack(spacing: 10) {
                        HStack(alignment: .center) {
                            LocationTag(country: viewModel.output.activityNewDetailList[index].country)
                            Spacer()
                        }
                        Spacer()
                    }.padding(10)
                    
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(viewModel.output.activityNewDetailList[index].title)
                            .appFont(PaperlogyFontStyle.title, textColor: .grayScale0)
                            .shadow(color: .black.opacity(0.6), radius: 2)
                        
                        Label {
                            Text("\(viewModel.output.activityNewDetailList[index].originalPrice)")
                                .appFont(PaperlogyFontStyle.caption, textColor: .grayScale0)
                                .shadow(color: .black.opacity(0.6), radius: 2)
                        } icon: {
                            Image(.iconWon)
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.grayScale0)
                        }
                        
                        Text(viewModel.output.activityNewDetailList[index].description)
                            .appFont(PretendardFontStyle.caption1, textColor: .grayScale30)
                            .lineSpacing(4)
                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                        
                        
                        
                    }
                    .padding()
                }
                .cornerRadius(15)
                .shadow(radius: 2)
            }
        }
        .frame(height: 300)
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
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
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


// MARK: Filter Result Section
extension HomeView {
    
    @ViewBuilder
    private func makeFilterResultView() -> some View {
        
        LazyVStack {
            ForEach(viewModel.output.filterActivityDetailList, id: \.activityID) { item in
                
                makeFilterImageView(item)
                makedescriptionView(item)
            }
        }
        
    }
    
    //
    private func makeFilterImageView(_ item: FilterActivityModel) -> some View {
        GeometryReader { geo in
            ZStack() {
                Image(uiImage: item.thumnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .background(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                makeBadgeView(item.isKeep, item.country, item.isAdvertisement)
                
                if item.isNewActiviy {
                     VStack {
                         Spacer()
                         ActivityOpenDisCountTag()
                             .offset(y: 10) // 바텀에서 10 아래로 내리기
                     }
                 }
                
            }
            
        }
        .frame(height: 200)
        .padding(.horizontal, 10)
    }
    
    private func makeBadgeView(_ isKeep: Bool, _ country: String, _ isAd: Bool) -> some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(alignment: .center, spacing: 0) {
                    ActivityKeepButtonView(isKeep: isKeep) {
                        /// ID를 보내줘야하나? 인덱스를 보내줘야하나?
                        print("here")
                    }
                    Spacer()
                    LocationTag(country: country)
                    
                }
                
                Spacer()
            }
            
            if isAd {
                HStack {
                    Spacer()
                    AdvertisementTag()
                }
            }
        }
        .padding(10)
        
    }
    
    /// 마감 임박 구현 필요
    private func lastChanceView() {
        
    }
    
    private func makedescriptionView(_ item:  FilterActivityModel) -> some View {
        
        VStack(alignment: .leading, spacing: 5) {
            makeFirstSection(item.title, item.keepCount, item.pointReward)
            makeDescriptionSection(item.description)
            makePriceSection(isDiscount: item.isDiscount, item.originalPrice, item.finalPrice, item.discountRate)
        }
        .padding([.top, .leading], 10)
        
        
    }
    
    
    private func makeFirstSection(_ title: String, _ heartCount: Int, _ pointReward :Int?) -> some View {
        
        HStack(alignment: .bottom, spacing: 10) {
            Text(title)
                .appFont(PretendardFontStyle.title1, textColor: .grayScale100)
            ActivityKeepLabel(heartCount: heartCount)
            if let pointReward {
                ActivityPointMoneyLabel(pointReward: pointReward)
            }
            Spacer()
        }
        
    }
    
    
    private func makeDescriptionSection(_ description: String) -> some View {
        Text(description)
            .appFont(PretendardFontStyle.caption1, textColor: .grayScale60)
            .lineSpacing(4)
    }
    
    /// Param:  originalPrice: 기본 가격, finalPrice: 최종 가격
    
    private func makePriceSection(isDiscount: Bool, _ originalPrice: Int, _ finalPrice: Int, _ discountRate: String) -> some View {
        
        let originalStyle = isDiscount ? PretendardFontStyle.body3 : PretendardFontStyle.body1
        let originalColor = isDiscount ? Color.grayScale60 : Color.grayScale100
        
        return HStack(alignment: .bottom, spacing: 15) {
            Text("\(originalPrice)원")
                .appFont(originalStyle, textColor: originalColor)
                .overlay(
                    GeometryReader { geo in
                        ZStack(alignment: .center) {
                            // 선
                            Rectangle()
                                .fill(.blackSeafoam)
                                .frame(height: 1)
                            
                            /// 화살표
                            Text("-→")
                                .appFont(PretendardFontStyle.caption1, textColor: .blackSeafoam)
                                .offset(x: geo.size.width / 2 + 1, y: -0.5) // 오른쪽으로 이동, 위로 이동
                        }
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                    }
                        .allowsHitTesting(false)
                )
            
            if isDiscount {
                Text("\(finalPrice)원")
                    .appFont(PretendardFontStyle.title1, textColor: .grayScale100)
                
                Text(discountRate)
                    .appFont(PretendardFontStyle.title1, textColor: .blackSeafoam)
                    .padding(.leading, -10)
            }
            
            Spacer()
        }
    }
}


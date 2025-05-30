//
//  ActivityIntroduceView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/29/25.
//

import SwiftUI

struct ActivityIntroduceView: View {
    
    
    @Binding var data: [FilterActivityModel]
    
    var onTapKeep: (String) -> Void
    var currentIndex: (Int) -> Void
    
    var body: some View {
        LazyVStack {
            ForEach(Array(zip(data.indices, data)), id: \.1.activityID) { index, item in
                VStack {
                    makeFilterImageView(item)
                    makedescriptionView(item)
                }
                .onAppear {
                    currentIndex(index)
                }
                
            }
       
        }
    }
}

extension ActivityIntroduceView {
    
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
                
                makeBadgeView(item)
                
                if let tag = item.eventTag {
                    VStack {
                        Spacer()
                        ActivityEventLongTagView(tag: tag)
                            .offset(y: 10) // 바텀에서 10 아래로 내리기
                    }
                }
                
            }
            
        }
        .frame(height: 200)
        .padding(.horizontal, 10)
    }
    
    private func makeBadgeView(_ item: FilterActivityModel) -> some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(alignment: .center, spacing: 0) {
                    ActivityKeepButtonView(isKeep: item.isKeep) {
                        onTapKeep(item.activityID)
                    }
                    Spacer()
                    LocationTagView(country: item.country)
                    
                }
                
                Spacer()
            }
            
            if item.isAdvertisement {
                HStack {
                    Spacer()
                    AdvertisementTagView()
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

//#Preview {
//    ActivityIntroduceView()
//}

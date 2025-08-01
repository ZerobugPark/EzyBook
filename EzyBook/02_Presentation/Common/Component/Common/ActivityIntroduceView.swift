//
//  ActivityIntroduceView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/29/25.
//

import SwiftUI

struct ActivityIntroduceView: View {
    
    
    var data: [FilterActivityModel]
    
    /// 뷰모델에서 contain보다는, 인덱스 기반으로 찾는게 시간복잡도가 O(1)이기 때문에, 인덱스를 보냄
    var onTapKeep: (Int) -> Void
    var currentIndex: (Int) -> Void
    var onItemTapped: (String) -> Void
    
    var body: some View {
        if data.isEmpty {
            VStack {
                Text("검색 결과가 없습니다.")
                    .appFont(PretendardFontStyle.body1)
                    .padding(.vertical, 30)
            }
        } else {
            LazyVStack {
                
                ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                    ActivityCardView(
                        item: item,
                        index: index,
                        onTapKeep: { onTapKeep(index) },
                        onAppear: { currentIndex(index) },
                        onTap: { onItemTapped(item.activityID) }
                    )
                    .onAppear { currentIndex(index) }
                    .onTapGesture {
                        onItemTapped(item.activityID)
                    }
                }
                
            }
        }
        
        
    }
}

extension ActivityIntroduceView {
    
    private struct ActivityCardView: View {
        let item: FilterActivityModel
        let index: Int
        let onTapKeep: () -> Void
        let onAppear: () -> Void
        let onTap: () -> Void
        
        var body: some View {
            VStack {
                ActivityImageView(
                    imagePath: item.thumnail,
                    eventTag: item.eventTag,
                    isKeep: item.isKeep,
                    country: item.country,
                    isAdvertisement: item.isAdvertisement,
                    onTapKeep: onTapKeep
                )
                ActivityDescriptionView(
                    title: item.title,
                    keepCount: item.keepCount,
                    pointReward: item.pointReward,
                    description: item.description,
                    isDiscount: item.isDiscount,
                    originalPrice: item.originalPrice,
                    finalPrice: item.finalPrice,
                    discountRate: item.discountRate
                )
            }
            .onAppear { onAppear() }
            .contentShape(Rectangle()) // 히팅박스 설정 (보인 뷰까지만 히트가 가능하도록)
            .onTapGesture { onTap() }
        }
        
        
        
        /// 마감 임박 구현 필요
        private func lastChanceView() {
            
        }
        
        
        
    }
    
    
    
    // MARK: - Activity Image View
    private struct ActivityImageView: View {
        let imagePath: String
        let eventTag: Tag?
        let isKeep: Bool
        let country: String
        let isAdvertisement: Bool
        let onTapKeep: () -> Void
        
        var body: some View {
            GeometryReader { geo in
                ZStack {
                    
                    if imagePath.isEmpty {
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        
                    } else {
                        RemoteImageView(path: imagePath)
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    

                    VStack {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .center, spacing: 0) {
                                ActivityKeepButtonView(isKeep: isKeep) {
                                    onTapKeep()
                                }
                                Spacer()
                                LocationTagView(country: country)
                            }
                            Spacer()
                        }
                        if isAdvertisement {
                            HStack {
                                Spacer()
                                AdvertisementTagView()
                            }
                        }
                    }
                    .padding(10)
                    
                    if let tag = eventTag {
                        VStack {
                            Spacer()
                            ActivityEventLongTagView(tag: tag)
                                .offset(y: 10)
                        }
                    }
                }
            }
            .frame(height: 200)
            .padding(.horizontal, 10)
        }
    }
    
    
    
    private struct ActivityDescriptionView: View {
        let title: String
        let keepCount: Int
        let pointReward: Int?
        let description: String
        let isDiscount: Bool
        let originalPrice: Int
        let finalPrice: Int
        let discountRate: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .bottom, spacing: 10) {
                    Text(title)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .appFont(PretendardFontStyle.title1, textColor: .grayScale100)
                    
                    ActivityKeepLabel(keepCount: keepCount)
                    
                    if let pointReward {
                        ActivityPointMoneyLabel(pointReward: pointReward)
                    }
                    
                    Spacer()
                }
                
                Text(description)
                    .appFont(PretendardFontStyle.caption1, textColor: .grayScale60)
                    .lineSpacing(4)
                
                ActivityPriceView(
                    isDiscount: isDiscount,
                    originalPrice: originalPrice,
                    finalPrice: finalPrice,
                    discountRate: discountRate
                )
            }
            .padding([.top, .leading], 10)
        }
    }
    // MARK: - Activity Price View
    private struct ActivityPriceView: View {
        let isDiscount: Bool
        let originalPrice: Int
        let finalPrice: Int
        let discountRate: String
        
        var body: some View {
            let originalStyle = isDiscount ? PretendardFontStyle.body3 : PretendardFontStyle.body1
            let originalColor = isDiscount ? Color.grayScale60 : Color.grayScale100
            
            HStack(alignment: .bottom, spacing: 15) {
                Text("\(originalPrice)원")
                    .appFont(originalStyle, textColor: originalColor)
                    .overlay(
                        ZStack {
                            Rectangle()
                                .fill(.blackSeafoam)
                                .frame(height: 1)
                            HStack {
                                Spacer()
                                Text("-→")
                                    .appFont(PretendardFontStyle.caption1, textColor: .blackSeafoam)
                                    .padding(.trailing, -10)
                                    .padding(.bottom, 0.85)
                            }
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
    
}





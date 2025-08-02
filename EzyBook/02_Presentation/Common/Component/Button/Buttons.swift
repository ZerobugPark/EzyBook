//
//  Buttons.swift
//  EzyBook
//
//  Created by youngkyun park on 8/1/25.
//

import SwiftUI

// MARK: Flag Button
struct FlagSelectionView: View {
    
    @Binding var selectedFlag: Flag
    let onSelect: (Flag) -> Void
    
    /// 버튼 컬럼
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(Flag.allCases) { flag in
                Button {
                    onSelect(flag)
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
        .padding(.horizontal, 10)
    }
}
// MARK: Filter Button
struct FilterSelectionView: View {
    
    @Binding var selectedFilter: Filter
    let onSelect: (Filter) -> Void
    
    private let rows = [GridItem(.flexible(), spacing: 20)]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows) {
                ForEach(Filter.allCases) { filter in
                    Button {
                        onSelect(filter)
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
            .padding(.horizontal, 10)
        }
    }
    
    
}


struct FloatingButton: View {
    let text: String
    var action: () -> Void

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    action()
                }) {
                    Label {
                        Text(text)
                            .appFont(PaperlogyFontStyle.caption, textColor: .grayScale0)
                    } icon: {
                        Image(.iconInfo)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundStyle(.grayScale0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.blackSeafoam))
                }
                .shadow(radius: 5)
                .padding(.trailing, 20)
                .padding(.bottom, 10)
            }
        }
    }
}

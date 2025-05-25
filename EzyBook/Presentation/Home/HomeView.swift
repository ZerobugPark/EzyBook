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
    

    /// 버튼 컬럼
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)
    
    /// 버튼 Rows
    private let rows = [GridItem(.flexible(), spacing: 20)]
    
    
    var body: some View {
        NavigationStack {
            VStack {
                makeFlagSelectionView()
                makeFilterSelectionView()
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
//    HomeView()
}


// MARK: flage Button
extension HomeView {
    
    private func makeFlagSelectionView() -> some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(Flag.allCases) { flag in
                makeFlagButton(flag)
            }
        }
        .padding(.horizontal, 30)
    }
    
    private func makeFlagButton(_ flag: Flag) -> some View {
        Button {
            selectedFlag = flag
            viewModel.action(.selectionChanged(flag: selectedFlag, filter: selectedFilter))
        } label: {
            VStack(alignment: .center, spacing: 0) {
                flag.image
                    .resizable()
                    .frame(width: 60, height: 60)
                if flag != .all {
                    Text(flag.rawValue)
                        .appFont(PretendardFontStyle.body1)
                        .foregroundStyle(selectedFlag == flag ? .blackSeafoam : .grayScale100)
                }
                
            }
            .frame(width: 80, height: 90)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedFlag == flag ? .deepSeafoam.opacity(0.3) : Color.white)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.grayScale75, lineWidth: 0.5)
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
                .appFont(PretendardFontStyle.body2)
                .foregroundStyle(selectedFlag.rawValue == filter.rawValue ? .blackSeafoam : .grayScale100)
                .padding(10)
            //.frame(width: 30, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 17)
                        .fill(selectedFilter == filter ? .deepSeafoam.opacity(0.3) : Color.white)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 17)
                        .stroke(.grayScale75, lineWidth: 0.5)
                }
            
        }
    }
}

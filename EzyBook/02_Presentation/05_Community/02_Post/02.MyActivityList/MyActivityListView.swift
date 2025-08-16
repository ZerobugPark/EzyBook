//
//  MyActivityListView.swift
//  EzyBook
//
//  Created by youngkyun park on 8/2/25.
//

import SwiftUI

struct MyActivityListView: View {
    
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel: MyActivityListViewModel
    @Environment(\.dismiss) private var dismiss
    let onConfirm: (OrderList) -> Void
    
    init(viewModel: MyActivityListViewModel, onConfirm: @escaping (OrderList) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onConfirm = onConfirm
    }
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                CommonNavigationBar(
                    title: "액티비티 조회", leadingAction: {
                        dismiss()
                    })
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.output.groupedOrderList) { group in
                        ActivityListGroupView(group: group) { order in
                            onConfirm(order)
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .disabled(viewModel.output.isLoading)
            LoadingOverlayView(isLoading: viewModel.output.isLoading)
        }
        .withCommonUIHandling(viewModel) { code, isSuccess in
            if isSuccess {
                dismiss() // 빈 배열일 때
            } else if code == 418 {
                appState.isLoggedIn = false
            }
        }
        
    }
}

private extension MyActivityListView {
    
    struct ActivityListGroupView: View {
        
        let group: GroupedOrder
        let onSelectOrder: (OrderList) -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(group.date.toDisplayDate())
                    .appFont(PaperlogyFontStyle.caption, textColor: .grayScale100)
                    .padding([.top, .leading], 4)
                
                ForEach(group.orders, id: \.orderID) { order in
                    ActivityListCardView(data: order) {
                        onSelectOrder(order)
                    }
                }
            }
        }
        
    }
    
    // MARK: - Card Component
    struct ActivityListCardView: View {
        let data: OrderList
        let onSelect: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(data.title)
                    .appFont(PretendardFontStyle.title1, textColor: .grayScale100)
                    .multilineTextAlignment(.leading)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("투어 일시: \(data.date) \(data.time)")
                        .appFont(PretendardFontStyle.body3, textColor: .grayScale60)
                    Text(data.country)
                        .appFont(PretendardFontStyle.body3, textColor: .grayScale75)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
            .background(.grayScale0)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
            .onTapGesture {
                onSelect()
            }
        }
    }
    
}

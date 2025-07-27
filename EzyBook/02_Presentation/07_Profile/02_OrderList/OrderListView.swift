//
//  OrderListView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/19/25.
//

import SwiftUI


// MARK: - Main View
struct OrderListView: View {

    @StateObject var viewModel: OrderListViewModel
    @ObservedObject var coordinator: ProfileCoordinator
    var onRatingUpdated: ((String, Int) -> Void)?
    
    @EnvironmentObject var appState: AppState
    @State private var selectedOrder: OrderList?
    
    
    var body: some View {
        
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.output.groupedOrderList) { group in
                        OrderListGroupView(group: group) { order in
                            selectedOrder = order
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButtonView {
                    coordinator.pop()
                }
            }
            ToolbarItem(placement: .principal) {
                Text("주문 내역")
                    .appFont(PaperlogyFontStyle.body, textColor: .blackSeafoam)
            }
        }
        .fullScreenCover(item: $selectedOrder) { order in
            coordinator.makeWriteReviewView(order.activityID, order.orderCode) { (orderCode, rating) in
                onRatingUpdated?(orderCode, rating)
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

extension OrderListView {
    
    private struct OrderListGroupView: View {
        
        let group: GroupedOrder
        let onSelectOrder: (OrderList) -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(group.date)
                    .appFont(PaperlogyFontStyle.caption, textColor: .grayScale100)
                    .padding([.top, .leading], 4)
                
                ForEach(group.orders, id: \.orderID) { order in
                    OrderListCardView(data: order) {
                        onSelectOrder(order)
                    }
                }
            }
        }
        
    }
    
    // MARK: - Card Component
    struct OrderListCardView: View {
        let data: OrderList
        let onSelect: () -> Void
        
        var body: some View {
            VStack(spacing: 0) {
                OrderListMainContentView(data: data)
                OrderListRatingView(data: data, onSelect: onSelect)
            }
            .background(.grayScale0)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        }
    }
    
    // MARK: - Main Content
    struct OrderListMainContentView: View {
        let data: OrderList
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(data.title)
                            .appFont(PretendardFontStyle.title1, textColor: .grayScale100)
                            .multilineTextAlignment(.leading)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(data.date) \(data.time)")
                                .appFont(PretendardFontStyle.body3, textColor: .grayScale60)
                            
                            Text(data.country)
                                .appFont(PretendardFontStyle.body3, textColor: .grayScale75)
                        }
                    }
                    
                    Spacer()
                    
                    Image(uiImage: data.image)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(16)
            .background(.grayScale0)
            .cornerRadius(12)
        }
    }

    
    // MARK: - Rating View
    struct OrderListRatingView: View {
        let data: OrderList
        let onSelect: () -> Void
        
        var body: some View {
            if data.hasRating {
                HStack(alignment: .center, spacing: 6) {
                    Spacer()
                    Image(.iconStarFill)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.rosyPunch)
                    
                    Text("\(data.rating!)")
                        .appFont(PretendardFontStyle.body2, textColor: .grayScale100)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
            } else {
                Button {
                    onSelect()
                } label: {
                    Text("리뷰 작성를 작성해주세요")
                }
                .font(.system(size: 14))
                .appFont(PretendardFontStyle.body2, textColor: .grayScale75)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
            }
        }
    }
 
}




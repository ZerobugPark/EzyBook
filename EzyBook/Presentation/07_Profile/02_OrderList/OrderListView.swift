//
//  OrderListView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/19/25.
//

import SwiftUI


// MARK: - Main View
struct OrderListView: View {
  
    let orderList: [OrderEntity]
    
    @StateObject var viewModel: OrderListViewModel
    @ObservedObject var coordinator: ProfileCoordinator
    
    var body: some View {
        
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.output.orderList, id: \.orderID) { list in
                        makeOrderListView(list)
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
        .onAppear {
            viewModel.action(.onAppearRequested(data: orderList))
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
        .loadingOverlayModify(viewModel.output.isLoading)
    }
}

extension OrderListView {
    
    
    private func makeOrderListView(_ data: OrderList) -> some View {
        VStack(spacing: 0) {
            makeMainContent(data)
            makeRatingView(data)
            
  
        }
        .background(.grayScale0)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    
    private func makeMainContent(_ data: OrderList) -> some View {
        // Main content card
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Text content
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
    
    
    @ViewBuilder
    private func makeRatingView(_ data: OrderList) -> some View {
        // Rating section
        if data.hasRating {
            HStack(alignment: .center, spacing: 6) {
                Spacer()
                
                Image(.iconStarFill)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.rosyPunch)
                
                
                Text(String(format: "%.1f", data.rating!))
                    .appFont(PretendardFontStyle.body2, textColor: .grayScale100)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
        } else {
            // Placeholder for activities without rating
            Button {
                
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




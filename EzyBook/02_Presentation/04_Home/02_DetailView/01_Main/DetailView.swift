//
//  DetailView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/2/25.
//

import SwiftUI
import AVKit

struct SelectedMedia: Identifiable {
    let id: Int
    let isVideo: Bool
}

struct DetailView: View {
    
    @EnvironmentObject var appState: AppState
    
    @StateObject var viewModel: DetailViewModel
    @ObservedObject  var coordinator: HomeCoordinator
    
    
    @State private var personCount = 1
    @State private var selectedDate: String? = nil
    @State private var selectedTime: String? = nil
    @State private var selectedIndex = 0
    
    /// 화면전환 트리거
    @State private var selectedMedia: SelectedMedia?
    
    private var data: ActivityDetailEntity {
        viewModel.output.activityDetailInfo
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    ZStack(alignment: .top) {
                        
                        ActivityTopMediaSection(
                            thumbnails: viewModel.output.thumbnails,
                            data: viewModel.output.activityDetailInfo,
                            reviews: viewModel.output.reviews,
                            selectedIndex: $selectedIndex,
                            selectedMedia: $selectedMedia
                        ) {
                            coordinator.push(.reviewView(activityID: viewModel.activityID))
                        }
                        
                        ThumbnailSelectorView(
                            thumbnails: viewModel.output.thumbnails,
                            selectedIndex: $selectedIndex
                        )
                    }
                    
   
                    makeActivityDetailInto(data: viewModel.output.activityDetailInfo)
                    
                    ActivityScheduleSection(schedules: viewModel.output.activityDetailInfo.schedule)
                    
                    ActivityReservationSection(
                        data: viewModel.output.activityDetailInfo,
                        selectedDate: $selectedDate,
                        selectedTime: $selectedTime,
                        personCount: $personCount,
                        isLoading: viewModel.output.isLoading
                    )
                    
                    
                    Spacer().frame(height: 150)
                }
                
            }
            .disabled(viewModel.output.isLoading)
            
            LoadingOverlayView(isLoading: viewModel.output.isLoading)
            
            VStack {
                ChatFloatingButton {
                    viewModel.action(.makeChatRoom)
                }
                
                ReservationPayBar(
                    finalPrice: data.price.final,
                    personCount: personCount,
                    selectedDate: selectedDate,
                    selectedTime: selectedTime
                ) {
                    guard let selectedDate, let selectedTime else { return }
                    viewModel.action(
                        .makeOrder(
                            id: viewModel.activityID,
                            name: selectedDate,
                            time: selectedTime,
                            count: personCount,
                            price: data.price.final * personCount
                        )
                    )
                }
            
                
            }
            .disabled(viewModel.output.isLoading)
            
            LoadingOverlayView(isLoading: viewModel.output.isLoading)
        }
        /// TabView에다가 붙이면
        .fullScreenCover(item: $selectedMedia) { media in
            if media.isVideo {
                coordinator.makeVideoPlayerView(path: data.thumbnailPaths[media.id])
            } else {
                coordinator.makeImageViewer(path: data.thumbnailPaths[media.id])
            }
        }
        .fullScreenCover(isPresented: $viewModel.output.payButtonTapped) {
            if let payItem = viewModel.output.payItem {
                coordinator.makePaymentView(item: payItem) { msg in
                    viewModel.action(.showPaymentResult(message: msg))
                }
            }
            
        }
        .ignoresSafeArea(.container, edges: .top)
        .background(.grayScale15)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButtonView {
                    coordinator.pop()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                ActivityKeepButtonView(isKeep: data.isKeep) {
                    viewModel.action(.keepButtonTapped)
                }
            }
        }
        .withCommonUIHandling(viewModel) { code, _ in
            if code == 418 {
                appState.isLoggedIn = false
            }
        }
        .onChange(of: viewModel.output.roomID) { newRoomID in
            if let id = newRoomID {
                coordinator.push(.chatRoomView(roomID: id, opponentNick: viewModel.output.opponentNick))
                viewModel.output.roomID = nil //  트리거 리셋
            }
        }
        .onDisappear {
            selectedDate = nil
        }
        .loadingOverlayModify(viewModel.output.isLoading)
    }
    
    
}

// MARK: Thumbnails Images
private extension DetailView {
    
    struct ActivityTopMediaSection: View {
        let thumbnails: [UIImage]
        let data: ActivityDetailEntity
        let reviews: ReviewRatingListEntity?
        
        @Binding var selectedIndex: Int
        @Binding var selectedMedia: SelectedMedia?
        
        var reviewAction: () -> Void
        
        var body: some View {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedIndex) {
                    ForEach(Array(thumbnails.enumerated()), id: \.0) { index, image in
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .clipped()
                            
                            if data.thumbnailPaths[index].hasSuffix(".mp4") {
                                Image(.playButton)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .shadow(radius: 10)
                            }
                        }
                        .onTapGesture {
                            let isVideo = data.thumbnailPaths[index].hasSuffix(".mp4")
                            selectedMedia = SelectedMedia(id: index, isVideo: isVideo)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 500)

                VStack(spacing: 8) {
                    indicatorView
                    titleSection
                }
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.grayScale60.opacity(0.0), location: 0.0),
                            .init(color: Color.grayScale60.opacity(0.3), location: 0.3),
                            .init(color: Color.grayScale60.opacity(0.5), location: 0.5),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: 100)
                    .edgesIgnoringSafeArea(.bottom)
                )
            }
        }

        private var indicatorView: some View {
            HStack(spacing: 6) {
                ForEach(0..<thumbnails.count, id: \.self) { index in
                    if index == selectedIndex {
                        Capsule()
                            .fill(.grayScale45)
                            .frame(width: 30, height: 8)
                            .transition(.scale)
                    } else {
                        Circle()
                            .fill(.grayScale60)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: selectedIndex)
        }

        private var titleSection: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(data.title)
                    .appFont(PaperlogyFontStyle.title, textColor: .grayScale100)
                
                HStack(spacing: 10) {
                    Text(data.country)
                        .appFont(PaperlogyFontStyle.caption, textColor: .grayScale45)
                    
                    ActivityPointMoneyLabel(pointReward: data.pointReward)
                    
                    Button(action: reviewAction) {
                        HStack(spacing: 4) {
                            Image(.iconStarFill)
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundStyle(.rosyPunch)
                            
                            Text(String(format: "%.1f", reviews?.rating ?? 0.0))
                                .appFont(PaperlogyFontStyle.caption, textColor: .grayScale100)
                            
                            Text("(\(reviews?.totalCount ?? 0))")
                                .appFont(PretendardFontStyle.body2, textColor: .grayScale100)
                            
                            Image(.iconChevron)
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.grayScale100)
                                .rotationEffect(.degrees(180))
                                .padding(.top, 1)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }
    
    

    struct ThumbnailSelectorView: View {
        let thumbnails: [UIImage]
        @Binding var selectedIndex: Int

        var body: some View {
            VStack(spacing: 10) {
                ForEach(Array(thumbnails.enumerated()), id: \.0) { index, image in
                    let isSelected = index == selectedIndex

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? Color.white : Color.clear, lineWidth: 5)
                        )
                        .scaleEffect(isSelected ? 1.25 : 1.0)
                        .shadow(color: isSelected ? Color.white.opacity(0.4) : .clear, radius: 8)
                        .padding(.vertical, isSelected ? 2 : 0)
                        .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                        .onTapGesture {
                            selectedIndex = index
                        }
                }
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(1.0))
            )
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 12)
            .padding(.top, 100)
        }
    }
    
}


// MARK: Description
private extension DetailView {
    
    private func makeActivityDetailInto(data: ActivityDetailEntity) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            /// 소개
            ActivityDescriptionSection(
                description: data.description,
                totalOrderCount: data.totalOrderCount,
                keepCount: data.keepCount
            )
            
            ActivityRestrictionsSection(restrictions: data.restrictions)
            ActivityPriceSection(price: data.price, discountRate: data.discountRate)
            
        }
        .padding(.horizontal)
    }
    
    
    
    struct ActivityDescriptionSection: View {
        let description: String
        let totalOrderCount: Int
        let keepCount: Int

        var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                Text(description)
                    .appFont(PretendardFontStyle.body3, textColor: .grayScale60)
                    .lineSpacing(4)

                HStack {
                    IconTextLabel(image: .iconBuy, text: "누적 구매 \(totalOrderCount)회")
                    IconTextLabel(image: .tabBarKeepFill, text: "KEEP \(keepCount)회")
                }
            }
            .padding(.top, 5)
        }
        
    }
    
    struct IconTextLabel: View {
        let image: ImageResource
        let text: String

        var body: some View {
            HStack(spacing: 4) {
                Image(image)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundStyle(.grayScale60)
                Text(text)
                    .appFont(PretendardFontStyle.caption1, textColor: .grayScale60)
            }
        }
    }
    
    // MARK: ActivityRestrictionsSection
    struct ActivityRestrictionsSection: View {
        let restrictions: ActivityRestrictionsEntity

        var body: some View {
            HStack(spacing: 4) {
                IconLabelBlock(image: .limitAge, topText: "연령제한", bottomText: "\(restrictions.minAge)세")
                IconLabelBlock(image: .limitHeight, topText: "신장제한", bottomText: "\(restrictions.minHeight)cm")
                IconLabelBlock(image: .limitPeople, topText: "최대참가인원", bottomText: "\(restrictions.maxParticipants)명")
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.grayScale45, lineWidth: 1)
            )
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    struct IconLabelBlock: View {
        let image: ImageResource
        let topText: String
        let bottomText: String

        var body: some View {
            HStack(alignment: .top, spacing: 5) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.grayScale15)
                        .frame(width: 40, height: 40)
                    
                    Image(image)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.grayScale45)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(topText)
                        .appFont(PretendardFontStyle.caption2, textColor: .grayScale75)
                    
                    Text(bottomText)
                        .appFont(PretendardFontStyle.body2, textColor: .grayScale100)
                }
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(12)
        }
    }
    
    // MARK: ActivityPriceSection
    struct ActivityPriceSection: View {
        let price: ActivityPriceEntity
        let discountRate: String

        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text("\(price.original)원")
                    .appFont(PaperlogyFontStyle.caption, textColor: .grayScale45)
                    .overlay {
                        Image(.discountArrow)
                            .resizable()
                            .frame(width: 120, height: 15)
                            .padding(.top, 15)
                            .padding(.leading, 50)
                    }

                HStack {
                    Text("판매가")
                        .appFont(PaperlogyFontStyle.body, textColor: .grayScale45)
                    Text("\(price.final)원")
                        .appFont(PaperlogyFontStyle.title, textColor: .grayScale90)
                    Text(discountRate)
                        .appFont(PaperlogyFontStyle.title, textColor: .blackSeafoam)
                }
            }
        }
    }
}


// MARK: ScheduleSection:
private extension DetailView {
    
    struct ActivityScheduleSection: View {
        let schedules: [ActivityScheduleItemEntity]

        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("액티비티 커리큘럼")
                    .appFont(PaperlogyFontStyle.caption, textColor: .grayScale45)
                
                makeScheduleSection()
            }
            .padding()
        }

        private func makeScheduleSection() -> some View {
            VStack(spacing: 0) {
                ForEach(Array(schedules.enumerated()), id: \.offset) { index, item in
                    makeScheduleItem(item: item, isLast: index == schedules.count - 1)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.grayScale45, lineWidth: 1)
            )
        }

        @ViewBuilder
        private func makeScheduleItem(item: ActivityScheduleItemEntity, isLast: Bool) -> some View {
            HStack(alignment: .top, spacing: 12) {
                makeTimelineIndicator(isLast: isLast)
                makeScheduleContent(item: item)
            }
            .padding(.bottom, isLast ? 0 : 20)
        }

        private func makeTimelineIndicator(isLast: Bool) -> some View {
            VStack(spacing: 0) {
                Circle()
                    .fill(.deepSeafoam)
                    .frame(width: 12, height: 12)
                
                if !isLast {
                    Rectangle()
                        .fill(.deepSeafoam)
                        .frame(width: 2)
                        .padding(.top, 4)
                }
            }
        }

        private func makeScheduleContent(item: ActivityScheduleItemEntity) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.duration)
                    .appFont(PretendardFontStyle.caption1, textColor: .grayScale75)
                
                Text(item.description)
                    .appFont(PretendardFontStyle.body1, textColor: .grayScale90)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
}


// MARK: ActivityReservationSection
private extension DetailView {
    struct ActivityReservationSection: View {
        let data: ActivityDetailEntity
        @Binding var selectedDate: String?
        @Binding var selectedTime: String?
        @Binding var personCount: Int
        let isLoading: Bool

        var body: some View {
            VStack(alignment: .leading) {
                reservationHeader()
                dateSelectionSection()
                
                if let selectedDate {
                    timeSelectionSection(for: selectedDate)
                }
                
                makeSelectedPersonSection()
            }
            .padding()
            .onChange(of: isLoading) { isLoading in
                if !isLoading, selectedDate == nil, !data.reservationList.isEmpty {
                    selectedDate = data.reservationList.first?.itemName
                }
            }
        }

        // MARK: - Header
        private func reservationHeader() -> some View {
            Text("액티비티 예약설정")
                .appFont(PaperlogyFontStyle.caption, textColor: .grayScale45)
        }

        // MARK: - 날짜 선택
        private func dateSelectionSection() -> some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(data.reservationList, id: \.itemName) { item in
                        dateButton(
                            date: item.itemName,
                            isSelected: selectedDate == item.itemName,
                            soldOut: item.soldOut
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }

        private func dateButton(date: String, isSelected: Bool, soldOut: Bool) -> some View {
            Button(action: {
                selectedDate = date
                selectedTime = nil
            }) {
                Text(formatDateString(date))
                    .appFont(
                        PretendardFontStyle.body3,
                        textColor: soldOut ? .grayScale60 : isSelected ? .deepSeafoam : .grayScale75)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(soldOut ? Color.grayScale30.opacity(0.5) : isSelected ? Color.deepSeafoam.opacity(0.1) : Color.grayScale0)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                soldOut ? Color.grayScale45.opacity(0.5) :
                                isSelected ? Color.deepSeafoam.opacity(0.1) :
                                Color.grayScale30,
                                lineWidth: 1
                            )
                    }
            }
        }

        // MARK: - 시간 선택
        @ViewBuilder
        private func timeSelectionSection(for date: String) -> some View {
            if let reservation = data.reservationList.first(where: { $0.itemName == date }) {
                VStack(alignment: .leading, spacing: 16) {
                    timeSection(title: "오전", times: reservation.times.filter { isAM($0.time) })
                    timeSection(title: "오후", times: reservation.times.filter { isPM($0.time) })
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.8)))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.grayScale45, lineWidth: 1))
            }
        }

        private func timeSection(title: String, times: [ActivityReservationTimeEntity]) -> some View {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .appFont(PretendardFontStyle.body3, textColor: .grayScale60)
                timeGrid(times: times)
            }
        }

        private func timeGrid(times: [ActivityReservationTimeEntity]) -> some View {
            let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
            return LazyVGrid(columns: columns, spacing: 12) {
                ForEach(times, id: \.time) { timeItem in
                    timeButton(timeItem: timeItem)
                }
            }
        }

        private func timeButton(timeItem: ActivityReservationTimeEntity) -> some View {
            Button {
                if !timeItem.isReserved {
                    selectedTime = timeItem.time
                }
            } label: {
                Text(timeItem.time)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(getTimeButtonTextColor(timeItem: timeItem))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(getTimeButtonBackgroundColor(timeItem: timeItem))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(getTimeButtonBorderColor(timeItem: timeItem), lineWidth: 1)
                    )
            }
            .disabled(timeItem.isReserved)
        }

        private func makeSelectedPersonSection() -> some View {
            HStack(alignment: .center) {
                Text("예약 인원")
                    .appFont(PaperlogyFontStyle.caption, textColor: .grayScale100)

                Spacer()

                HStack(spacing: 16) {
                    Button {
                        if personCount > 1 { personCount -= 1 }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(.blackSeafoam)
                            .clipShape(Circle())
                    }

                    Text("\(personCount)")
                        .appFont(PaperlogyFontStyle.caption, textColor: .grayScale100)

                    Button {
                        if personCount < data.restrictions.maxParticipants {
                            personCount += 1
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(.blackSeafoam)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.8)))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.grayScale45, lineWidth: 1))
        }

        // MARK: - Helpers
        private func formatDateString(_ dateString: String) -> String {
            let components = dateString.split(separator: "-")
            if components.count == 3,
               let month = Int(components[1]),
               let day = Int(components[2]) {
                return "\(month)월 \(day)일"
            }
            return dateString
        }

        private func isAM(_ time: String) -> Bool {
            (Int(time.split(separator: ":").first ?? "0") ?? 0) < 12
        }

        private func isPM(_ time: String) -> Bool {
            (Int(time.split(separator: ":").first ?? "0") ?? 0) >= 12
        }

        private func getTimeButtonTextColor(timeItem: ActivityReservationTimeEntity) -> Color {
            if timeItem.isReserved {
                return .grayScale60
            } else if selectedTime == timeItem.time {
                return .deepSeafoam
            } else {
                return .grayScale100
            }
        }

        private func getTimeButtonBackgroundColor(timeItem: ActivityReservationTimeEntity) -> Color {
            if timeItem.isReserved {
                return .grayScale60.opacity(0.1)
            } else if selectedTime == timeItem.time {
                return .deepSeafoam.opacity(0.3)
            } else {
                return .grayScale0
            }
        }

        private func getTimeButtonBorderColor(timeItem: ActivityReservationTimeEntity) -> Color {
            if selectedTime == timeItem.time && !timeItem.isReserved {
                return .deepSeafoam
            } else {
                return .grayScale45
            }
        }
    }
}


// MARK: Others
extension DetailView {
    
    struct ChatFloatingButton: View {
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
                            Text("문의하기")
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
    
    
    struct ReservationPayBar: View {
        let finalPrice: Int
        let personCount: Int
        let selectedDate: String?
        let selectedTime: String?
        let onPay: () -> Void
        
        var body: some View {
            HStack(alignment: .center) {
                Text("\(finalPrice * personCount)원")
                    .appFont(PaperlogyFontStyle.body, textColor: .grayScale100)
                    .padding(.leading, 10)
                
                Spacer()
                
                Button {
                    onPay()
                } label: {
                    Text("결제하기")
                        .frame(width: 100)
                        .padding()
                        .background(
                            (selectedDate == nil || selectedTime == nil)
                            ? Color.grayScale45
                            : Color.blackSeafoam
                        )
                        .appFont(PaperlogyFontStyle.body, textColor: .grayScale0)
                        .cornerRadius(7)
                }
                .disabled(selectedDate == nil || selectedTime == nil)
            }
            .padding()
            .background(Color.grayScale0.ignoresSafeArea(edges: .bottom))
        }
    }
    
}

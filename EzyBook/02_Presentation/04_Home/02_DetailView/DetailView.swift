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
    
    @Environment(\.displayScale) var scale
    @EnvironmentObject var appState: AppState
    
    @StateObject var viewModel: DetailViewModel
    @ObservedObject  var coordinator: HomeCoordinator
    
    private(set) var activityID: String
    
    @State private var personCount = 1
    @State private var selectedDate: String? = nil
    @State private var selectedTime: String? = nil
    
    /// 화면전환 트리거
    @State private var selectedMedia: SelectedMedia?
    
    private var data: ActivityDetailEntity {
        viewModel.output.activityDetailInfo
    }
    
    @State private var selectedIndex = 0
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    ZStack(alignment: .top) {
                        makeTapImageView()
                        makeThumnailView()
                    }
                    makeActivityDetailIntoView()
                    makeScheduleView()
                    makeReservationView()
                    
                    Spacer().frame(height: 150)
                }
                
            }
            .disabled(viewModel.output.isLoading)
            
            VStack {
                makeChatButton()
                makePayView()
            }
            
            LoadingOverlayView(isLoading: viewModel.output.isLoading)
        }
        /// TabView에다가 붙이면
        .fullScreenCover(item: $selectedMedia) { media in
            if media.isVideo {
                coordinator.makeVideoPlayerView(path: data.thumbnails[media.id])
            } else {
                coordinator.makeImageViewer(path: data.thumbnails[media.id])
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
//        .commonAlert(
//            isPresented: Binding(
//                get: { viewModel.output.isShowingError },
//                set: { isPresented in
//                    if !isPresented {
//                        viewModel.action(.resetError)
//                    }
//                }
//            ),
//            title: viewModel.output.presentedError?.message.title,
//            message: viewModel.output.presentedError?.message.msg
//        )
        .onAppear {
            /// 최초 한번만 되게? 수정해야할거 같은데. (그 다음은 강제 업데이트)
            /// onAppear를 하다보니까, 알라모가 1~2초 이내에 들어온것은 같은 통신인줄 알고 걍 304 해버리는 듯
            /// 즉, 결제 -> OnAppear -> 결제가 성공되면 다시 onAppearRequested 호출
            viewModel.action(.onAppearRequested(id: activityID))
            
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


/// 메인 섹션
extension DetailView {
    
    private func makeTapImageView() -> some View {
        ZStack(alignment: .bottom) {
            // 이미지 페이징
            TabView(selection: $selectedIndex) {
                ForEach(Array(viewModel.output.thumbnails.enumerated()), id: \.0) { index, image in
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .clipped()
                        
                        //TODO: 첫번째 뿐마 아니라, 두번째나 세번째도 동영상일 수 있음, 수정 필요
                        if index == 0 && viewModel.output.hasMovieThumbnail {
                            Image(.playButton)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .shadow(radius: 10)
                        }
                    }
                    .onTapGesture {
                        selectedMedia = SelectedMedia(id: index, isVideo: index == 0 && viewModel.output.hasMovieThumbnail)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // ✅ 기본 인디케이터 숨김
            .frame(height: 500)
            // 하단 오버레이 (텍스트 + 그라데이션 + 커스텀 인디케이터)
            VStack(spacing: 8) {
                makeIndicator()
                makeTitleSection()
                
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
    
    
    private func makeIndicator() -> some View {
        // 커스텀 인디케이터
        HStack(spacing: 6) {
            ForEach(Array(viewModel.output.thumbnails.enumerated()), id: \.0) { index, _ in
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
    
    private func makeTitleSection() -> some View {
        // 텍스트 정보
        VStack(alignment: .leading, spacing: 4) {
            Text(data.title)
                .appFont(PaperlogyFontStyle.title, textColor: .grayScale100)
            HStack(spacing: 10) {
                Text(data.country)
                    .appFont(PaperlogyFontStyle.caption, textColor: .grayScale45)
                ActivityPointMoneyLabel(pointReward: data.pointReward)
                
                makeReviewView()
                
            }
            
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        
        
    }
    
    private func makeThumnailView() -> some View {
        
        VStack(spacing: 10) {
            ForEach(Array(viewModel.output.thumbnails.enumerated()), id: \.0) { index, image in
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
                    .scaleEffect(isSelected ? 1.25 : 1.0) //
                    .shadow(color: isSelected ? Color.white.opacity(0.4) : .clear, radius: 8)
                    .padding(.vertical, isSelected ? 2 : 0) // 간격 유지용
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
    
    private func makeReviewView() -> some View {
        
        Button {
            coordinator.push(.reviewView(activityID: activityID))
        } label: {
            HStack(spacing: 4) {
                Image(.iconStarFill)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(.rosyPunch)
                Text(String(format: "%.1f", viewModel.output.reviews?.rating ?? 0.0))
                    .appFont(PaperlogyFontStyle.caption, textColor: .grayScale100)
                Text("(\(viewModel.output.reviews?.totalCount ?? 0))")
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

// MARK: 상세 설명
extension DetailView {
    
    private func makeActivityDetailIntoView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            makeDescriptionSection()
            makerestrictionsSection()
            makeActivityPriceView()
        }
        .padding(.horizontal)
    }
    
    private func makeDescriptionSection() -> some View {
        VStack(alignment: .leading,spacing: 15) {
            Text(data.description)
                .appFont(PretendardFontStyle.body3, textColor: .grayScale60)
                .lineSpacing(4)
            
            HStack {
                makeTotalOrderCountView()
                makeKeepCountView()
            }
        }
        .padding(.top, 5)
        
    }
    
    private func makerestrictionsSection() -> some View {
        HStack(spacing: 4) {
            makeIconLabelBlock(image: .limitAge, topText: "연령제한", bottomText: "\(data.restrictions.minAge)세")
            makeIconLabelBlock(image: .limitHeight, topText: "신장제한", bottomText: "\(data.restrictions.minHeight)cm")
            makeIconLabelBlock(image: .limitPeople, topText: "최대참가인원", bottomText: "\(data.restrictions.maxParticipants)명")
            
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
    
    
    
    private func makeIconLabelBlock(
        image: ImageResource,
        topText: String,
        bottomText: String
    ) -> some View {
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
    
    
    private func makeTotalOrderCountView() -> some View {
        
        HStack(spacing: 4) {
            Image(.iconBuy)
                .renderingMode(.template)
                .resizable()
                .frame(width: 15, height: 15)
                .foregroundStyle(.grayScale60)
            Text("누적 구매 \(data.totalOrderCount)회")
                .appFont(PretendardFontStyle.caption1, textColor: .grayScale60)
        }
    }
    
    private func makeKeepCountView() -> some View {
        
        HStack(spacing: 4) {
            Image(.tabBarKeepFill)
                .renderingMode(.template)
                .resizable()
                .frame(width: 15, height: 15)
                .foregroundStyle(.grayScale60)
            Text("KEEP \(data.keepCount)회")
                .appFont(PretendardFontStyle.caption1, textColor: .grayScale60)
        }
    }
    
    
    private func makeActivityPriceView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            
            Text("\(data.price.original)원")
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
                Text("\(data.price.final)원")
                    .appFont(PaperlogyFontStyle.title, textColor: .grayScale90)
                Text(data.discountRate)
                    .appFont(PaperlogyFontStyle.title, textColor: .blackSeafoam)
            }
        }
        
    }
}

// MARK: 스케줄 섹션
extension DetailView {
    
    private func makeScheduleView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("액티비티 커리큘럼")
                .appFont(PaperlogyFontStyle.caption, textColor: .grayScale45)
            makeScheduleSection()
        }
        .padding()
    }
    
    
    private func makeScheduleSection() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // 일정 리스트
            scheduleList()
                .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.grayScale45, lineWidth: 1)
        )
    }
    
    
    /// 일정 리스트 뷰
    private func scheduleList() -> some View {
        VStack(spacing: 0) {
            ForEach(Array(data.schedule.enumerated()), id: \.offset) { index, item in
                scheduleItem(
                    item: item,
                    isLast: index == data.schedule.count - 1
                )
            }
        }
    }
    
    ///  개별 일정 아이템 뷰
    @ViewBuilder
    private func scheduleItem(item: ActivityScheduleItemEntity, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // 타임라인 인디케이터
            timelineIndicator(isLast: isLast)
            
            // 일정 내용
            scheduleContent(item: item)
        }
        .padding(.bottom, isLast ? 0 : 20)
    }
    
    /// 타임라인 인디케이터
    @ViewBuilder
    private func timelineIndicator(isLast: Bool) -> some View {
        VStack(spacing: 0) {
            // 원형 인디케이터
            Circle()
                .fill(.deepSeafoam)
                .frame(width: 12, height: 12)
            
            // 연결선 (마지막 항목이 아닌 경우)
            if !isLast {
                Rectangle()
                    .fill(.deepSeafoam)
                    .frame(width: 2)
                    .padding(.top, 4)
            }
        }
    }
    
    /// 일정 내용
    private func scheduleContent(item: ActivityScheduleItemEntity) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // 시간
            Text(item.duration)
                .appFont(PretendardFontStyle.caption1, textColor: .grayScale75)
            
            // 제목
            Text(item.description)
                .appFont(PretendardFontStyle.body1, textColor: .grayScale90)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}


// MARK: 예약 섹션
extension DetailView {
    
    private func makeReservationView() -> some View {
        
        VStack(alignment: .leading) {
            // 헤더
            reservationHeader()
            
            // 날짜 선택
            dateSelectionSection()
            
            // 선택된 날짜의 시간 선택
            if let selectedDate = selectedDate {
                timeSelectionSection(for: selectedDate)
            }
            
            makeSelectedPersonSection()
        }
        .onChange(of: viewModel.output.isLoading) { isLoading in
            if !isLoading, selectedDate == nil, !data.reservationList.isEmpty {
                selectedDate = data.reservationList[0].itemName
            }
        }
        
        
        .padding()
        
    }
    
    
    // MARK: - 헤더
    @ViewBuilder
    private func reservationHeader() -> some View {
        Text("액티비티 예약설정")
            .appFont(PaperlogyFontStyle.caption, textColor: .grayScale45)
    }
    
    // MARK: - 날짜 선택 섹션
    @ViewBuilder
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
    
    // MARK: - 개별 날짜 버튼
    private func dateButton(date: String, isSelected: Bool, soldOut: Bool) -> some View {
        Button(action: {
            selectedDate = date
            selectedTime = nil // 날짜 변경시 선택된 시간 초기화
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
                    /// .storke는 패딩에 따라서 차이가 있을 수 있음
                    /// .strokeBorder를 사용하면 내부에서 그리기 때문에, 패딩이랑 상관 없음
                        .strokeBorder(soldOut ? Color.grayScale45.opacity(0.5) : isSelected ? Color.deepSeafoam.opacity(0.1) : Color.grayScale30, lineWidth: 1)
                }
        }
    }
    
    // MARK: - 시간 선택 섹션
    @ViewBuilder
    private func timeSelectionSection(for date: String) -> some View {
        if let reservation = data.reservationList.first(where: { $0.itemName == date }) {
            VStack(alignment: .leading, spacing: 16) {
                // 오전 시간
                timeSection(
                    title: "오전",
                    times: reservation.times.filter { isAM($0.time) }
                )
                
                // 오후 시간
                timeSection(
                    title: "오후",
                    times: reservation.times.filter { isPM($0.time) }
                )
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
    }
    
    /// 시간대별 섹션 (오전/오후)
    @ViewBuilder
    private func timeSection(title: String, times: [ActivityReservationTimeEntity]) -> some View {
        if !times.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .appFont(PretendardFontStyle.body3, textColor: .grayScale60)
                timeGrid(times: times)
            }
        }
    }
    
    /// 시간 그리드
    @ViewBuilder
    private func timeGrid(times: [ActivityReservationTimeEntity]) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
        
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(times, id: \.time) { timeItem in
                timeButton(timeItem: timeItem)
            }
        }
    }
    
    // MARK: - 개별 시간 버튼
    private func timeButton(timeItem: ActivityReservationTimeEntity) -> some View {
        Button(action: {
            if !timeItem.isReserved {
                selectedTime = timeItem.time
            }
        }) {
            Text(timeItem.time)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(getTimeButtonTextColor(timeItem: timeItem))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(getTimeButtonBackgroundColor(timeItem: timeItem))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(getTimeButtonBorderColor(timeItem: timeItem), lineWidth: 1)
                }
        }
        .disabled(timeItem.isReserved)
    }
    
    // MARK: - Helper Functions
    private func formatDateString(_ dateString: String) -> String {
        // "2025-12-06" -> "5월 6일" 형태로 변환
        let components = dateString.split(separator: "-")
        if components.count == 3,
           let month = Int(components[1]),
           let day = Int(components[2]) {
            return "\(month)월 \(day)일"
        }
        return dateString
    }
    
    private func isAM(_ time: String) -> Bool {
        let hour = Int(time.split(separator: ":")[0]) ?? 0
        return hour < 12
    }
    
    private func isPM(_ time: String) -> Bool {
        let hour = Int(time.split(separator: ":")[0]) ?? 0
        return hour >= 12
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
    
    private func makeSelectedPersonSection() -> some View {
        
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("예약 인원")
                    .appFont(PaperlogyFontStyle.caption, textColor: .grayScale100)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    if personCount > 1 {
                        personCount -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(.blackSeafoam)
                        .clipShape(Circle())
                }
                
                Text("\(personCount)")
                    .appFont(PaperlogyFontStyle.caption, textColor: .grayScale100)
                    .frame(minWidth: 20)
                
                Button(action: {
                    if personCount <= data.restrictions.maxParticipants {
                        personCount += 1
                    }
                }) {
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
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.grayScale45, lineWidth: 1)
        )
    }
    
    
}


// MARK: 채팅
extension DetailView {
    
    private func makeChatButton() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    viewModel.action(.makeChatRoom)
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

// MARK: Bottom
extension DetailView {
    
    private func makePayView() -> some View {
        
        HStack(alignment: .center) {
            Text("\(data.price.final * personCount)원")
                .appFont(PaperlogyFontStyle.body, textColor: .grayScale100)
                .padding(.leading, 10)
            
            Spacer()
            Button {
                
                guard let selectedDate, let selectedTime else { return }
                
                
                viewModel.action(.makeOrder(id: activityID, name: selectedDate, time: selectedTime, count: personCount, price: data.price.final * personCount))
                
            } label: {
                Text("결제하기")
                    .frame(width: 100)
                    .padding()
                    .background(
                        (selectedDate == nil || selectedTime == nil) ? .grayScale45 :
                                .blackSeafoam)
                    .appFont(PaperlogyFontStyle.body, textColor: .grayScale0)
                    .cornerRadius(7)
            }
            .disabled(selectedDate == nil || selectedTime == nil)
        }
        .padding()
        .background(Color.grayScale0.ignoresSafeArea(edges: .bottom)) // 배경이 바닥까지 닿게
    }
    
}




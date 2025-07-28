//
//  ChatListView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/22/25.
//

import SwiftUI

struct ChatListView: View {
    
    @StateObject var viewModel: ChatListViewModel
    @ObservedObject var coordinator: ChatCoordinator
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        
        ScrollView {
            LazyVStack {
                ForEach(viewModel.output.chatRoomList, id: \.id) { item in
                    makeChatListView(item)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            coordinator.push(.chatRoomView(roomID: item.roomID, opponentNick: item.participants[item.opponentIndex ?? 0].nick))
                        }
                        
                        
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                TitleTextView(title: "채팅")
            }
            
        }
        .withCommonUIHandling(viewModel) { code, _ in
            if code == 418 {
                appState.isLoggedIn = false
            }
        }
        .onAppear {
            viewModel.action(.showChatRoomList)
        }
       
    }
        
}


/// 채팅 목록
extension ChatListView {
    
    func makeChatListView(_ data: ChatRoomEntity) -> some View {
        
        HStack(alignment: .top, spacing: 10) {
            ProfileImageView(image: data.opponentImage, size: 44)
            
            VStack(alignment: .leading, spacing: 5) {
                /// 채팅하는 사람
                Text(data.participants[data.opponentIndex ?? 0].nick)
                    .appFont(PretendardFontStyle.body1, textColor: .grayScale100)
                    .lineLimit(1)
                    .truncationMode(.tail)
                /// 마지막 채팅 내역
                Text(data.lastChat!.content)
                    .appFont(PretendardFontStyle.body2, textColor: .grayScale60)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            Spacer()
            Text(formatDate(data.createdAt))
                .appFont(PretendardFontStyle.body3, textColor: .grayScale75)
        }
        .padding()
        
    }
    
    func formatDate(_ isoDateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: isoDateString) else {
            return "-"
        }

        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            return timeFormatter.string(from: date)
        }

        if calendar.isDateInYesterday(date) {
            return "어제"
        }

        let inputYear = calendar.component(.year, from: date)
        let currentYear = calendar.component(.year, from: now)

        let dateFormatter = DateFormatter()
        if inputYear == currentYear {
            dateFormatter.dateFormat = "MM.dd"
        } else {
            dateFormatter.dateFormat = "yyyy.MM.dd"
        }

        return dateFormatter.string(from: date)
    }
    
}


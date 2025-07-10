//
//  ChatListView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/22/25.
//

import SwiftUI

struct ChatListView: View {
    
    @StateObject var viewModel: ChatListViewModel
    
    var body: some View {
        
        ScrollView {
            LazyVStack {
                ForEach(viewModel.output.chatRoomList, id: \.id) { item in
                    makeChatListView(item)
                        
                }
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
            ProfileImageView(size: 44)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(data.lastChat!.sender.nick)
                    .appFont(PretendardFontStyle.body1, textColor: .grayScale100)
                    .lineLimit(1)
                    .truncationMode(.tail)
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
        print("dsmakldmsalkmdksalmdl")
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


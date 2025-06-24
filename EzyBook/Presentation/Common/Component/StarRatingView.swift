//
//  StarRatingView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/20/25.
//

import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int
    let maximumRating: Int = 5

    var body: some View {
        HStack {
            ForEach(1 ..< maximumRating + 1, id: \.self) { number in
                Image(systemName: "star.fill")
                    .foregroundColor(number <= rating ? .rosyPunch : .gray)
                    .onTapGesture {
                        rating = number
                    }
            }
        }
    }
}

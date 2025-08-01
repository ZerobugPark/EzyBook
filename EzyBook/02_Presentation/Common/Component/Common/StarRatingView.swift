//
//  StarRatingView.swift
//  EzyBook
//
//  Created by youngkyun park on 6/20/25.
//

import SwiftUI

struct StarRatingView: View {
    @Binding private var rating: Int
    private let isInteractive: Bool
    private let size: CGFloat
    private let maximumRating: Int
    private let spacing: CGFloat
    
    init(rating: Binding<Int>, size: CGFloat = 17, maximumRating: Int = 5, spacing: CGFloat = 8) {
        self._rating = rating
        self.isInteractive = true
        self.size = size
        self.maximumRating = maximumRating
        self.spacing = spacing
    
     }

     init(staticRating: Int, size: CGFloat = 10, maximumRating: Int = 5, spacing: CGFloat = 0) {
         self._rating = .constant(staticRating)
         self.isInteractive = false
         self.size = size
         self.maximumRating = maximumRating
         self.spacing = spacing
     }
    

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1 ..< maximumRating + 1, id: \.self) { number in
                Image(systemName: "star.fill")
                    .font(.system(size: size))
                    .foregroundColor(number <= rating ? .rosyPunch : .gray)
                    .onTapGesture {
                        if isInteractive {
                            rating = number
                        }
                        
                    }
            }
        }
    }
}

//
//  StarRatingSlider.swift
//  WildLog
//
//  Created by Avanish Davuluri on 3/11/26.
//

import SwiftUI

public struct StarRatingSlider: View {
    @Binding public var rating: Double // e.g. 1.0, 1.5, ..., 5.0
    let maximum: Int = 5
    let starSize: CGFloat = 32
    let spacing: CGFloat = 8 // Distance between stars

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...maximum, id: \.self) { i in
                starView(for: i)
                    .frame(width: starSize, height: starSize)
            }
        }
        .gesture(
            // I'm not even going to try to figure out a good min distance
            // Allow sliding up and down to 0
            DragGesture()
                .onChanged { value in
                    let totalWidth = CGFloat(maximum) * (starSize + spacing) - spacing
                    let x = min(max(value.location.x, 0), totalWidth)
                    let rawRating = x / (starSize + spacing)
                    let halfStep = (rawRating * 2).rounded() / 2
                    rating = min(max(halfStep, 0), Double(maximum))
                }
        )
        .animation(.easeInOut, value: rating)
    }

    // Converts current rating to appropriate star symbol
    private func starView(for index: Int) -> some View {
        let starValue = Double(index)
        let symbol: String
        if rating >= starValue {
            symbol = "star.fill"
        } else if rating >= starValue - 0.5 {
            symbol = "star.leadinghalf.filled"
        } else {
            symbol = "star"
        }
        return Image(systemName: symbol)
            .resizable()
            .aspectRatio(contentMode: .fit)
            // Green like the rest of the app
            .foregroundColor(Color(.systemGreen))
    }
}

#Preview {
    StarRatingSlider(rating: .constant(3.5))
}

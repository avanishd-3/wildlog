//
//  ReviewCard.swift
//  WildLog
//
//  Created by Derek Cao on 2/13/26.
//

import SwiftUI


// Star Rating Display
// Reviws tab doesn't need the sliding capability of the write reviews reviews (rating is immutable here)
struct StarRatingView: View {
    let rating: Double
    let maxRating: Int = 5

    var body: some View {
        HStack(spacing: 3) {
            ForEach(1...maxRating, id: \.self) { star in
                let filled = Double(star) <= rating
                let halfFilled = !filled && Double(star) - 0.5 <= rating

                Image(systemName: filled ? "star.fill" : halfFilled ? "star.leadinghalf.filled" : "star")
            }
        }
    }
}

// Review Card

// TODO: Add a NavigationLink so tapping a card will navigate to a full review
// TODO: Reviews should show an avatar/profile photo
struct ReviewCard: View {
    let review: ParkReview

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(review.authorName)
                if review.isCurrentUser {
                    Text("· You")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(review.visitedDate, style: .date)
                    .foregroundStyle(.secondary)
            }

            Text(review.parkName)
                .foregroundStyle(.secondary)

            StarRatingView(rating: review.rating)

            if !review.description.isEmpty {
                Text(review.description)
            }
        }
        .padding()
    }
}

// Preview

#Preview {
    ReviewCard(review: ParkReview(
        id: UUID(),
        authorName: "Alex Kim",
        parkName: "Yosemite National Park",
        rating: 4.5,
        description: "El Capitan at sunrise is worth every early alarm.",
        visitedDate: .now
    ))
}

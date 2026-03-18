//
//  ReviewData.swift
//  WildLog
//
//  Created by Avanish Davuluri on 3/18/26.
//

import SwiftUI

class ReviewData {
    static let friendReviews: [ParkReview] = [
        ParkReview(
            id: UUID(),
            authorName: "Alex Kim",
            parkName: "Yosemite National Park",
            rating: 5,
            description: "El Capitan at sunrise is something else entirely.",
            visitedDate: Calendar.current.date(byAdding: .day, value: -3, to: .now)!
        ),
        ParkReview(
            id: UUID(),
            authorName: "Jordan Lee",
            parkName: "Joshua Tree National Park",
            rating: 4,
            description: "Incredible night sky. Bring extra water.",
            visitedDate: Calendar.current.date(byAdding: .day, value: -10, to: .now)!
        ),
    ]
    
    static let yourReviews: [ParkReview] = [
        ParkReview(
            id: UUID(),
            authorName: "You",
            parkName: "Sequoia National Park",
            rating: 5,
            description: "Standing next to General Sherman is humbling.",
            visitedDate: Calendar.current.date(byAdding: .day, value: -30, to: .now)!,
            isCurrentUser: true
        ),
    ]
}

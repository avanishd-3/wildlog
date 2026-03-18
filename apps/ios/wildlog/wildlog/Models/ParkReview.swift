//
//  ParkReview.swift
//  WildLog
//
//  Created by Avanish Davuluri on 3/18/26.
//

import Foundation
import WildLogAPI


struct ParkReview: Identifiable {
    let id: UUID
    let authorName: String
    let parkName: String
    let rating: Double  // Stored in DB increments of .5 (from 1 - 5)
    let description: String
    let visitedDate: Date
    var isCurrentUser: Bool = false
}

// Custom inits for ParkReview
extension ParkReview {
    
    // See: https://developer.apple.com/documentation/foundation/iso8601dateformatter
    // For converting from string Date to Date object (backend sends & stores times in ISO format)
    private static let dateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        formatter.formatOptions.insert(.withInternetDateTime)
        return formatter
    }
    
    init?(from gql:GetReviewPageRecommendationsQuery.Data.MeReview) {
        let date = ParkReview.dateFormatter().date(from: gql.visitedDate) // Convert string to date type
        self.init(
            id: UUID(uuidString: gql.id) ?? UUID(),
            authorName: "You", // No need to get name from backend (me reviews are only from current user)
            parkName: gql.parkName,
            rating: Double(gql.rating) ?? 0.0,
            description: gql.reviewText ?? "",
            visitedDate: date ?? Date(), // Optional for compile, parsing shouldn't fail if formatter options are properly set
            isCurrentUser: true // Known b/c this is the me review
        )
    }
    
    init?(from gql:GetReviewPageRecommendationsQuery.Data.FriendReview) {
        let date = ParkReview.dateFormatter().date(from: gql.visitedDate) // Convert string to date type
        self.init(
            id: UUID(uuidString: gql.id) ?? UUID(),
            authorName: gql.authorName,
            parkName: gql.parkName,
            rating: Double(gql.rating) ?? 0.0,
            description: gql.reviewText ?? "",
            visitedDate: date ?? Date(), // Optional for compile, parsing shouldn't fail if formatter options are properly set
            isCurrentUser: false // Known b/c this is the friend review
        )
    }
}

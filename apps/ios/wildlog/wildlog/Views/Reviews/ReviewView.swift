//
//  ReviewView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import SwiftUI

struct ReviewView: View {
    @State private var selectedTab = 0
    @State private var showWriteReview = false
    
    // This is just a preview sample to demonstrate what the UI might look like
    // The arrays will eventually be replaced with Apollo query results
    let friendReviews: [ParkReview] = [
        ParkReview(
            authorName: "Alex Kim",
            authorInitials: "AK",
            parkName: "Yosemite National Park",
            rating: 5,
            description: "El Capitan at sunrise is something else entirely.",
            visitedDate: Calendar.current.date(byAdding: .day, value: -3, to: .now)!
        ),
        ParkReview(
            authorName: "Jordan Lee",
            authorInitials: "JL",
            parkName: "Joshua Tree National Park",
            rating: 4,
            description: "Incredible night sky. Bring extra water.",
            visitedDate: Calendar.current.date(byAdding: .day, value: -10, to: .now)!
        ),
    ]
    
    let yourReviews: [ParkReview] = [
        ParkReview(
            authorName: "You",
            authorInitials: "ME",
            parkName: "Sequoia National Park",
            rating: 5,
            description: "Standing next to General Sherman is humbling.",
            visitedDate: Calendar.current.date(byAdding: .day, value: -30, to: .now)!,
            isCurrentUser: true
        ),
    ]

    var displayedReviews: [ParkReview] {
        selectedTab == 0 ? friendReviews : yourReviews
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("", selection: $selectedTab) {
                    Text("Friends").tag(0)
                    Text("You").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(displayedReviews) { review in
                            ReviewCard(review: review)
                                .padding(.horizontal)
                        }
                    }
                }

                Spacer()
            }
            .navigationTitle("Reviews")
            .toolbar {
                // This will eventually pass the current park context into WriteReview
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showWriteReview = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showWriteReview) {
                WriteReviewSheet()
            }
        }
    }
}

#Preview {
    ReviewView()
}

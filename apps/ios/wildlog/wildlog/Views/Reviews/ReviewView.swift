//
//  ReviewView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import SwiftUI
import WildLogAPI

// This should only be for looking at reviews (not writing them)
struct ReviewView: View {
    @State private var selectedTab = 0
    
    // Need to be state so UI is updated when these are changed on refresh
    @State var friendReviews: [ParkReview] = []
    @State var yourReviews: [ParkReview] = []

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
        }
        .onAppear {
            Task {
                do {
                    let response = try await apolloClient.fetch(query: GetReviewPageRecommendationsQuery())
                    
                    friendReviews = response.data?.friendReviews?.compactMap { ParkReview(from: $0) } ?? []
                    yourReviews = response.data?.meReviews?.compactMap { ParkReview(from: $0) } ?? []
                } catch {
                    // TODO: Handle error
                }
            }
        }
    }
}

#Preview {
    ReviewView(friendReviews: ReviewData.friendReviews, yourReviews: ReviewData.yourReviews)
}

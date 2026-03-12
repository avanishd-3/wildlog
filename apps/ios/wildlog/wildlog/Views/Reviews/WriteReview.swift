//
//  WriteReview.swift
//  wildlog
//
//  Created by Derek Cao on 2/13/26.
//

import SwiftUI
import WildLogAPI

// Write Review Sheet

struct Review {
    var starRating: Double = 0
    var descriptionText: String = ""
    var visitedDate: Date = .now
}

struct WriteReviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    // Accept optional park parameter for quick review from ParkDetailView
    var park: Park?
    
    // If no park provided, default to placeholder (for toolbar button in ReviewView)
    var parkName: String {
        park?.name ?? "Select a park"
    }
    
    @State private var reviewInfo: Review = .init()
    @State private var savingNewInfo = false
    
    // To close view
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dimiss

    var canSubmit: Bool {
        reviewInfo.starRating > 0 && park != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Park") {
                    Text(parkName)
                }

                Section("Rating") {
                    StarRatingSlider(rating: $reviewInfo.starRating)
                }
                
                Section("Visited") {
                    DatePicker("Date", selection: $reviewInfo.visitedDate, displayedComponents: .date)
                }

                Section("Description") {
                    TextEditor(text: $reviewInfo.descriptionText)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Write a Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        Task {
                            do {
                                savingNewInfo = true
                                let parkIdString = park?.id.uuidString ?? ""
                                let visitedAtString = reviewInfo.visitedDate.description
                                let _ = try await apolloClient.perform(mutation: SubmitReviewMutation(parkPublicId: parkIdString, review: reviewInfo.descriptionText, rating: String(reviewInfo.starRating), visitedAt: visitedAtString))
                                
                                savingNewInfo = false
                                isFocused = false
                                dimiss()
                            } catch {
                                // TODO: Handle update error
                            }
                        }
                    }
                    .tint(Color(.systemGreen))
                    .disabled(savingNewInfo)
                }
            }
        }
        .onAppear {
            guard let park = park else { return }
            Task {
                do {
                    let parkIdString = park.id.uuidString
                    let result = try await apolloClient.fetch(query: GetUserReviewQuery(parkPublicId: parkIdString))
                    if let review = result.data?.getUserReview {
                        reviewInfo = Review(
                            starRating: Double(review.rating) ?? 0,
                            descriptionText: review.reviewText ?? "",
                            visitedDate: ISO8601DateFormatter().date(from: review.visitedAt ?? "") ?? .now
                        )
                    }
                } catch {
                    // Handle error (optional)
                }
            }
        }
    }
}



#Preview {
    WriteReviewSheet(park: ParkData.sampleParks[0])
}

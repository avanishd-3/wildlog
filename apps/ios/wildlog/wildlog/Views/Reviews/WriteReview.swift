//
//  WriteReview.swift
//  wildlog
//
//  Created by Derek Cao on 2/13/26.
//

import SwiftUI
import WildLogAPI

// Write Review Sheet

struct WriteReviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    // Accept optional park parameter for quick review from ParkDetailView
    var park: Park?
    
    // If no park provided, default to placeholder (for toolbar button in ReviewView)
    var parkName: String {
        park?.name ?? "Select a park"
    }
    
    @State private var Review: Review?

    @State private var starRating: Double = 0
    @State private var descriptionText: String = ""
    @State private var visitedDate: Date = .now
    @State private var savingNewInfo: Bool = false
    
    // To close view
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dimiss

    var canSubmit: Bool {
        starRating > 0 && park != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Park") {
                    Text(parkName)
                }

                Section("Rating") {
                    StarRatingSlider(rating: $starRating)
                }
                
                Section("Visited") {
                    DatePicker("Date", selection: $visitedDate, displayedComponents: .date)
                }

                Section("Description") {
                    TextEditor(text: $descriptionText)
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
                                let visitedAtString = visitedDate.description
                                let _ = try await apolloClient.perform(mutation: SubmitReviewMutation(parkPublicId: parkIdString, review: descriptionText, rating: String(starRating), visitedAt: visitedAtString))
                                
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
    }
}


#Preview {
    WriteReviewSheet(park: ParkData.sampleParks[0])
}

//
//  WriteReview.swift
//  wildlog
//
//  Created by Derek Cao on 2/13/26.
//

import SwiftUI

// Write Review Sheet

struct WriteReviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    // Accept optional park parameter for quick review from ParkDetailView
    var park: Park?
    
    // If no park provided, default to placeholder (for toolbar button in ReviewView)
    var parkName: String {
        park?.name ?? "Select a park"
    }

    @State private var starRating: Double = 0
    @State private var descriptionText: String = ""
    @State private var visitedDate: Date = .now

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
                        // TODO: wire up Apollo mutation here
                        dismiss()
                    }
                    .tint(Color(.systemGreen))
                    .disabled(!canSubmit)
                }
            }
        }
    }
}


#Preview {
    WriteReviewSheet(park: ParkData.sampleParks[0])
}

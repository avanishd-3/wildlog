//
//  WriteReview.swift
//  wildlog
//
//  Created by Derek Cao on 2/13/26.
//

import SwiftUI

// Interactive Star Rating (Input)

struct InteractiveStarRatingView: View {
    @Binding var rating: Int

    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .onTapGesture {
                        rating = star == rating ? 0 : star
                    }
            }
        }
    }
}

// Write Review Sheet

struct WriteReviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    
    // TODO: Replace hardcoded default with parkID + parkName
    
    var parkName: String = "Yosemite National Park"

    @State private var starRating: Int = 0
    @State private var descriptionText: String = ""

    var canSubmit: Bool { starRating > 0 }

    var body: some View {
        NavigationStack {
            Form {
                Section("Park") {
                    Text(parkName)
                }

                Section("Rating") {
                    InteractiveStarRatingView(rating: $starRating)
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
                    .disabled(!canSubmit)
                }
            }
        }
    }
}


#Preview {
    WriteReviewSheet(parkName: "Yosemite National Park")
}

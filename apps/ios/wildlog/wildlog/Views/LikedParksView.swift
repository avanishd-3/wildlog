//
//  LikedParksView.swift
//  WildLog
//
//  Created by Derek Cao on 3/4/26.
//

import SwiftUI
import WildLogAPI

struct LikedParksView: View {
    @Environment(LikeManager.self) private var likeManager
    @State private var likedParks: [Park] = []
    @State private var fetchErrorFlag: Bool = false
    
    var body: some View {
        NavigationStack {
            if fetchErrorFlag {
                Text("Error fetching liked parks... Please try again later.")

            }
            
            else {
                GridView(parks: likedParks)
            }
        }
        .navigationTitle("Liked Parks")
        .task {
            Task {
                do {
                    let response = try await apolloClient.fetch(query: GetLikedParksQuery())
                    if let parksResponse = response.data?.likedParks {
                        likedParks = parksResponse.compactMap { Park(from: $0) }
                    }
                } catch {
                    // Update so error state is shown
                    fetchErrorFlag = true
                }
            }
            
        }
    }
}

#Preview {
    LikedParksView()
        .environment(LikeManager())
}

//
//  LikedParksView.swift
//  WildLog
//
//  Created by Derek Cao on 3/4/26.
//

import SwiftUI

// TODO: Replace with Apollo query that fetches user's liked parks from backend
// Query should return parks where user has created a "like" relationship in Neo4j

struct LikedParksView: View {
    @Environment(LikeManager.self) private var likeManager
    
    // TODO: This will be replaced with actual Park objects from GraphQL
    // For now just showing the IDs
    
    var body: some View {
        NavigationStack {
            if likeManager.likedParkIds.isEmpty {
                ContentUnavailableView(
                    "No Liked Parks",
                    systemImage: "heart.slash",
                    description: Text("Parks you like will appear here")
                )
            } else {
                List {
                    // TODO: Replace with ForEach over actual Park objects from Apollo query
                    ForEach(Array(likeManager.likedParkIds), id: \.self) { parkId in
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                            Text("Park ID: \(parkId)")
                            // TODO: Show actual park name, image, etc from Park object
                        }
                    }
                }
                .navigationTitle("Liked Parks")
            }
        }
    }
}

#Preview {
    LikedParksView()
        .environment(LikeManager())
}

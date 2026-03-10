//
//  BucketListView.swift
//  WildLog
//
//  Created by Derek Cao on 3/6/26.
//

import SwiftUI

// TODO: Replace with Apollo query that fetches user's bucket list parks from backend
// Query should return parks where user has created a "wants to visit" relationship in Neo4j

struct BucketListView: View {
    @Environment(BucketListManager.self) private var bucketListManager
    
    // TODO: This will be replaced with actual Park objects from GraphQL
    // For now just showing the IDs
    
    var body: some View {
        NavigationStack {
            if bucketListManager.bucketListParkIds.isEmpty {
                ContentUnavailableView(
                    "No Parks in Bucket List",
                    systemImage: "list.bullet.clipboard",
                    description: Text("Parks you want to visit will appear here")
                )
            } else {
                List {
                    // TODO: Replace with ForEach over actual Park objects from Apollo query
                    ForEach(Array(bucketListManager.bucketListParkIds), id: \.self) { parkId in
                        HStack {
                            Image(systemName: "flag.fill")
                                .foregroundStyle(.orange)
                            Text("Park ID: \(parkId)")
                            // TODO: Show actual park name, image, etc from Park object
                        }
                    }
                }
                .navigationTitle("Bucket List")
            }
        }
    }
}

#Preview {
    BucketListView()
        .environment(BucketListManager())
}

//
//  BucketListView.swift
//  WildLog
//
//  Created by Derek Cao on 3/6/26.
//

import SwiftUI
import WildLogAPI

struct BucketListView: View {
    @Environment(BucketListManager.self) private var likeManager
    @State private var bucketListedParks: [Park] = []
    @State private var fetchErrorFlag: Bool = false
    
    var body: some View {
        NavigationStack {
            if fetchErrorFlag {
                Text("Error fetching bucket listed parks... Please try again later.")

            }
            
            else {
                GridView(parks: bucketListedParks)
            }
        }
        .navigationTitle("Bucket Listed Parks")
        .task {
            Task {
                do {
                    let response = try await apolloClient.fetch(query: GetBucketListedParksQuery())
                    if let parksResponse = response.data?.bucketListedParks {
                        bucketListedParks = parksResponse.compactMap { Park(from: $0) }
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
    BucketListView()
        .environment(BucketListManager())
}

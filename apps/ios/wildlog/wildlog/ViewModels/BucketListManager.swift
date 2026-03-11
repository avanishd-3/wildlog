//
//  BucketListManager.swift
//  wildlog
//
//  Created by Derek Cao on 3/6/26.
//

import SwiftUI
import WildLogAPI

// Manages bucket list across the app
// TODO: Wire this to Apollo mutations for creating/deleting bucket list items in the backend

@Observable
class BucketListManager {
    private let storageKey = "bucketListParkIds"
    
    // Store the set directly as a tracked property
    var bucketListParkIds: Set<String> {
        didSet {
            saveToDisk()
        }
    }
    
    init() {
        // Load from UserDefaults on init
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.bucketListParkIds = decoded
        } else {
            self.bucketListParkIds = []
        }
    }
    
    private func saveToDisk() {
        if let data = try? JSONEncoder().encode(bucketListParkIds) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    func isInBucketList(_ parkId: String) -> Bool {
        bucketListParkIds.contains(parkId)
    }
    
    func toggleBucketList(for parkId: String) {
        if bucketListParkIds.contains(parkId) {
            bucketListParkIds.remove(parkId)
            Task {
                do {
                    let _ = try await apolloClient.perform(mutation: RemoveParkFromBucketListMutation(parkPublicId: parkId))
                    
                    // Do nothing, removing anyway
                }
            }
        } else {
            bucketListParkIds.insert(parkId)
            Task {
                do {
                    let response = try await apolloClient.perform(mutation: AddParktoBucketListMutation(parkPublicId: parkId))
                    
                    //
                    if !(response.data?.addToBucketList ?? false) {
                        bucketListParkIds.remove(parkId)
                    }
                }
            }
        }
    }
}

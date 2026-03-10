//
//  BucketListManager.swift
//  wildlog
//
//  Created by Derek Cao on 3/6/26.
//

import SwiftUI

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
            // TODO: Call Apollo mutation to delete bucket list item from backend
        } else {
            bucketListParkIds.insert(parkId)
            // TODO: Call Apollo mutation to create bucket list item in backend
        }
    }
}

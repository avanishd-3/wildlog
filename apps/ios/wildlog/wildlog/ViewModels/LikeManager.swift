//
//  LikeManager.swift
//  wildlog
//
//  Created by Derek Cao on 3/4/26.
//

import SwiftUI

// Manages park likes across the app
// TODO: Wire this to Apollo mutations for creating/deleting likes in the backend

@Observable
class LikeManager {
    private let storageKey = "likedParkIds"
    
    // Store the set directly as a tracked property
    var likedParkIds: Set<String> {
        didSet {
            saveToDisk()
        }
    }
    
    init() {
        // Load from UserDefaults on init
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.likedParkIds = decoded
        } else {
            self.likedParkIds = []
        }
    }
    
    private func saveToDisk() {
        if let data = try? JSONEncoder().encode(likedParkIds) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    func isLiked(_ parkId: String) -> Bool {
        likedParkIds.contains(parkId)
    }
    
    func toggleLike(for parkId: String) {
        if likedParkIds.contains(parkId) {
            likedParkIds.remove(parkId)
            // TODO: Call Apollo mutation to delete like from backend
        } else {
            likedParkIds.insert(parkId)
            // TODO: Call Apollo mutation to create like in backend
        }
    }
}

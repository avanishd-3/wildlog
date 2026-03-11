//
//  LikeManager.swift
//  wildlog
//
//  Created by Derek Cao on 3/4/26.
//

import SwiftUI
import WildLogAPI

// Manages park likes across the app

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
            Task {
                do {
                    let _ = try await apolloClient.perform(mutation: UnlikeParkMutation(parkPublicId: parkId))
                    
                    // Do nothing, removing anyway
                }
            }
        } else {
            likedParkIds.insert(parkId) // Optimistic update
            Task {
                do {
                    let response = try await apolloClient.perform(mutation: LikeParkMutation(parkPublicId: parkId))
                    
                    //
                    if !(response.data?.likePark ?? false) {
                        likedParkIds.remove(parkId)
                    }
                }
            }
        }
    }
}

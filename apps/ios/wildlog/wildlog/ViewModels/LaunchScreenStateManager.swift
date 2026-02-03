//
//  LaunchScreenStateManager.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import Foundation

final class LaunchScreenStateManager: ObservableObject {
    @MainActor @Published private(set) var state: LaunchScreenStep = .firstStep
    
    // End launch screen animation
    @MainActor func dismiss() {
        Task {
            self.state = .finished
        }
    }
}

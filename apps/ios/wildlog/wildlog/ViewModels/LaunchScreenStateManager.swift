//
//  LaunchScreenStateManager.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import Foundation

@Observable
final class LaunchScreenStateManager {
    @MainActor private(set) var state: LaunchScreenStep = .firstStep
    
    // End launch screen animation
    @MainActor func dismiss() {
        self.state = .finished
    }
}

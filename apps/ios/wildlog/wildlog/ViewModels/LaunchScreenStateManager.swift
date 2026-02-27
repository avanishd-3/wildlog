//
//  LaunchScreenStateManager.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import Foundation

final class LaunchScreenStateManager: Observable {
    @MainActor private(set) var state: LaunchScreenStep = .firstStep
    
    // End launch screen animation
    @MainActor func dismiss() {
        self.state = .finished
    }
}

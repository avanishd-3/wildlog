//
//  StringExtension.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/3/26.
//

// Keys for App storage
// Extension here for type inference
// MARK: App Storage is easily read, only use it for simple user settings (no sensitive data)
extension String {
    
    static var settingsUserNotificationKey: String { // If they have notifications on or off
        "settings.userNotification"
    }
}

//
//  StringExtension.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/3/26.
//

// Keys for App storage
// Extension here for type inference
extension String {
    
    static var settingsNameKey: String { // This is their actual name, not their username
        "settings.name"
    }
    
    static var settingsUserEmailKey: String {
        "settings.userEmail"
    }
    
    static var settingsUserWebsiteKey: String {
        "settings.userWebsite"
    }
    
    static var settingsBioKey: String {
        "settings.bio"
    }
    
    static var settingsUserNotificationKey: String { // If they have notifications on or off
        "settings.userNotification"
    }
}

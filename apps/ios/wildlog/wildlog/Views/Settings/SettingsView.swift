//
//  SettingsView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/3/26.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage(.settingsNameKey)
    private var name: String = ""
    
    @AppStorage(.settingsUserEmailKey)
    private var userEmail: String = ""
    
    @AppStorage(.settingsUserWebsiteKey)
    private var userWebsite: String = ""
    
    @AppStorage(.settingsBioKey)
    private var userBio: String = ""
    
    @AppStorage(.settingsUserNotificationKey)
    private var userNotification: Bool = false
    
    // Placeholder
    // TODO: Use actual logic to handle
    @State private var favoriteParks = [
        "zion",
        "yosemite",
        "bryce",
        "acadia"
    ]
    
    var body: some View {
        NavigationStack {
            // Text content types allow system to autocomplete for the user
            // They also put default values in the field when empty
            // See: https://developer.apple.com/documentation/swiftui/view/textcontenttype(_:)-ufdv
            Form {
                Section(header: Text("Profile")) {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                    TextField("Email Address", text: $userEmail)
                        .textContentType(.emailAddress)
                    TextField("Website", text: $userWebsite)
                        .textInputAutocapitalization(.never)
                        .textContentType(.URL)
                    NavigationLink { // Already provides arrow on right
                        BioView(bio: $userBio)
                    } label: {
                        HStack {
                            Text("Bio")
                            Spacer()
                        }
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Receive push notifications", isOn: $userNotification)
                }
                
            }
            .navigationBarTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}

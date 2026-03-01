//
//  SettingsView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/3/26.
//

import SwiftUI

struct SettingsView: View {
    
    @Binding var selectedTab: Tabs
    
    @Binding var name: String
    @Binding var email: String
    @Binding var userWebsite: String
    @Binding var userBio: String
    
    @AppStorage(.settingsUserNotificationKey)
    private var userNotification: Bool = false
    
    @Environment(AuthenticationManager.self) var authManager
    
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
                    TextField("Given Name", text: $name)
                        .textContentType(.name)
                    TextField("Email Address", text: $email)
                        .textContentType(.emailAddress)
                        .disabled(true)
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
                
                Section(header: Text("Sign Out")) {
                    Button("Sign Out") {
                        Task {
                            do {
                                
                                try await authManager.logout()
                                debugPrint("Signing out...")
                                
                                // Selected tab will be profile on log-in if you don't do this
                                debugPrint("Setting selectedTab to .home")
                                selectedTab = .home
                            } catch {
                                debugPrint("Logout failed: \(error)")
                            }
                        }
                    }
                    .foregroundStyle(Color(.systemRed))
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
    SettingsView(selectedTab: .constant(.home), name: .constant("John"), email: .constant("john@example.com"), userWebsite: .constant("https://john.example.com"), userBio: .constant("Hello, world!")).environment(AuthenticationManager())
}

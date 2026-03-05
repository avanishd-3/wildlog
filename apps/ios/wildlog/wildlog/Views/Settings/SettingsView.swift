//
//  SettingsView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/3/26.
//

import SwiftUI
import WildLogAPI

struct SettingsView: View {
    
    @Binding var selectedTab: Tabs
    
    @Binding var name: String
    @Binding var email: String
    @Binding var userWebsite: String
    @Binding var userBio: String
    
    @AppStorage(.settingsUserNotificationKey)
    private var userNotification: Bool = false
    
    @Environment(AuthenticationManager.self) var authManager
    
    @State private var savingNewInfo: Bool = false
    
    @Environment(\.dismiss) private var dimiss // To close view
    @FocusState private var isFocused: Bool

    @State private var showDeleteAccountConfirmation: Bool = false
    @State private var password: String = "" // Make user enter password to confirm account deletion
    @State private var showDeleteAccountSheet: Bool = false // Password entry field
    @State private var isDeletingAccount: Bool = false
    
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
                
                // Delete account
                Section(header: Text("Delete Account")) {
                    Button("Delete Account") {
                        showDeleteAccountConfirmation = true
                    }
                    .foregroundStyle(Color(.systemRed))
                    .confirmationDialog("Delete Account Confirmation", isPresented: $showDeleteAccountConfirmation) {
                        
                            Button("Delete Account") {
                                // Set sheet to true
                                showDeleteAccountSheet = true
                                
                            }
                            
                            Button("Cancel", role:.cancel) {
                                showDeleteAccountConfirmation = false
                            }
                    } message: {
                        Text("Deleting your account removes your content from the WildLog platform immediately. Once an account is permanently deleted, it cannot be recovered")
                            .font(.body)
                    }
                }
            }
            .navigationBarTitle("Settings")
            .sheet(isPresented: $showDeleteAccountSheet) {
                VStack(spacing: 20) {
                    Text("Confirm Account Deletion")
                        .font(.title2)
                    Text("Please enter your password to confirm account deletion. This action cannot be undone.")
                        .multilineTextAlignment(.center)
                    // Horizontal padding so it doesn't go to edge of space
                    SecureFieldWithEyeToggle(password: $password)
                        .padding([.horizontal, .top])
                    HStack {
                        Button("Cancel") {
                            showDeleteAccountSheet = false
                            password = ""
                        }
                        Spacer()
                        Button("Confirm Delete") {
                            isDeletingAccount = true
                            // TODO: Add your delete logic here, e.g.:
                            showDeleteAccountSheet = false
                            password = ""
                            isDeletingAccount = false
                        }
                        .foregroundColor(.red)
                        .disabled(password.isEmpty || isDeletingAccount)
                    }
                    .padding() // So cancel and confirm delete buttons aren't at the end of the text
                }
                .presentationDetents([.medium])
                
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            do {
                                savingNewInfo = true
                                let response = try await apolloClient.perform(mutation: UpdateUserInfoMutation(name: name, website: userWebsite))
                                
                                name = response.data?.updateBaseUserInfo?.name ?? name
                                userWebsite = response.data?.updateBaseUserInfo?.website ?? userWebsite
                                
                                savingNewInfo = false
                                isFocused = false
                                dimiss()
                            } catch {
                                // TODO: Handle update error
                            }
                        }
                    }
                    .tint(Color(.systemGreen))
                    .disabled(savingNewInfo)
                }
            }
        }
    }
}

#Preview {
    SettingsView(selectedTab: .constant(.home), name: .constant("John"), email: .constant("john@example.com"), userWebsite: .constant("https://john.example.com"), userBio: .constant("Hello, world!")).environment(AuthenticationManager())
}

//
//  ContentView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

// Landing page view for the app
// Just contains all the 

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tabs = .home
    
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    
    var body: some View {
        if #available(iOS 18.0, *) {
            TabView(selection: $selectedTab) {
                Tab("Home", systemImage: "house", value: .home) {
                    HomeView()
                }
                Tab("Your Lists", systemImage: "list.bullet", value: .lists) {
                    ListView()
                }
                Tab("Search", systemImage: "magnifyingglass", value: .map) {
                    SearchView()
                }
                Tab("Reviews", systemImage: "sparkles", value: .reviews) {
                    ReviewView()
                }
                Tab("Profile", systemImage: "person.crop.circle", value: .profile) {
                    ProfileView()
                }
            }
            .accentColor(Color(.systemGreen))
            .task {
                // TODO: Replace with actual API call
                // This is just a placeholder for now
                try? await Task.sleep(for: .seconds(3))
                self.launchScreenState.dismiss()
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LaunchScreenStateManager())
    }
}

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
    @State var selectedTab: Tabs = .home
    
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    
    var body: some View {
            
        // **Important**: Do not set tint or accent color. It applies globally
        UIKitTabView(selectedTab: $selectedTab)
        .task {
            // TODO: Replace with actual API call
            // This is just a placeholder for now
            try? await Task.sleep(for: .seconds(3))
            self.launchScreenState.dismiss()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LaunchScreenStateManager())
    }
}

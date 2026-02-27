//
//  ContentView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

// Landing page for the app

import SwiftUI

struct ContentView: View {
    @State var selectedTab: Tabs = .home
    @Environment(AuthenticationManager.self) var authManager
    
    // Do not allow app access until they are authenticated
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                UIKitTabView(selectedTab: $selectedTab)
            } else {
                AuthContainerView()
            }
        }
        .task {
            let isAuthenticated = await authManager.checkAuthenticationStatus()
            await MainActor.run {
                authManager.isAuthenticated = isAuthenticated
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(LaunchScreenStateManager())
            .environment(AuthenticationManager())
    }
}

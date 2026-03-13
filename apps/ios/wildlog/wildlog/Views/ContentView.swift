//
//  ContentView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

// Landing page for the app

import SwiftUI
import WildLogAPI

struct ContentView: View {
    @State var selectedTab: Tabs = .home
    @State var homeData: HomePageParkRecommendations = .init(from: [])
    
    @Environment(LaunchScreenStateManager.self) var launchScreenStateManager
    @Environment(AuthenticationManager.self) var authManager
    
    func dismissLaunchScreenWithLog() {
        debugPrint("Dismissing launch screen")
        launchScreenStateManager.dismiss()
    }
    
    // Do not allow app access until they are authenticated
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                UIKitTabView(selectedTab: $selectedTab, homeData: $homeData)
            } else {
                AuthContainerView()
            }
        }
        .task {
            let isAuthenticated = await authManager.checkAuthenticationStatus()
            await MainActor.run {
                authManager.isAuthenticated = isAuthenticated
                debugPrint("Authenticated: \(isAuthenticated)")
                
                // Only dismiss launch screen if not authenticated
                // So they can go to the log-in/sign-up view
                if !isAuthenticated {
                    dismissLaunchScreenWithLog()
                }
            }
            
            if isAuthenticated {
                do {
                    let result = try await apolloClient.fetch(query: GetHomePageRecommendationsQuery())
                    debugPrint("Got result back from recommendations query")
                    if let community = result.data?.getCommunityRecommendations {
                        homeData.communityParks = community.compactMap { Park(from: $0) }
                    }
                    if let forYou = result.data?.getForYouRecommendations {
                        homeData.forYouParks = forYou.compactMap { Park(from: $0) }
                    }
                    
                    dismissLaunchScreenWithLog()
                } catch {
                    print("Failed to load recommendations: \(error)")
                    dismissLaunchScreenWithLog()
                }
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

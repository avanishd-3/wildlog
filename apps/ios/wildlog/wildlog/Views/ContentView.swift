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
    @State private var isLoading: Bool = false
    @State private var hasFetchedRecommendations: Bool = false
    @State private var didInitialAuthCheck: Bool = false
    
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
                if isLoading {
                    VStack {
                        Spacer()
                        ProgressView("Loading recommendations...")
                        Spacer()
                    }
                } else {
                    UIKitTabView(selectedTab: $selectedTab, homeData: $homeData)
                }
            } else {
                AuthContainerView()
            }
        }
        .onChange(of: authManager.isAuthenticated) {
            if !authManager.isAuthenticated {
                homeData = .init(from: [])
                hasFetchedRecommendations = false
            } else if didInitialAuthCheck && !hasFetchedRecommendations {
                // User just logged in, fetch recommendations and show spinner
                isLoading = true
                Task {
                    do {
                        let result = try await apolloClient.fetch(query: GetHomePageRecommendationsQuery())
                        debugPrint("Got result from recommendations query after login")
                        await MainActor.run {
                            if let community = result.data?.getCommunityRecommendations {
                                homeData.communityParks = community.compactMap { Park(from: $0) }
                            }
                            if let forYou = result.data?.getForYouRecommendations {
                                homeData.forYouParks = forYou.compactMap { Park(from: $0) }
                            }
                            hasFetchedRecommendations = true
                            isLoading = false
                        }
                    } catch {
                        print("Failed to load recommendations after login: \(error)")
                        await MainActor.run { isLoading = false }
                    }
                }
            }
        }
        .task {
            let isAuthenticated = await authManager.checkAuthenticationStatus()
            await MainActor.run {
                authManager.isAuthenticated = isAuthenticated
                debugPrint("Authenticated: \(isAuthenticated)")
                didInitialAuthCheck = true
                // Only dismiss launch screen if not authenticated
                // So they can go to the log-in/sign-up view
                if !isAuthenticated {
                    dismissLaunchScreenWithLog()
                }
            }
            // Only fetch if authenticated and not already fetched
            if isAuthenticated && !hasFetchedRecommendations {
                isLoading = true
                do {
                    let result = try await apolloClient.fetch(query: GetHomePageRecommendationsQuery())
                    debugPrint("Got result from recommendations query in content view")
                    await MainActor.run {
                        if let community = result.data?.getCommunityRecommendations {
                            homeData.communityParks = community.compactMap { Park(from: $0) }
                        }
                        if let forYou = result.data?.getForYouRecommendations {
                            homeData.forYouParks = forYou.compactMap { Park(from: $0) }
                        }
                        hasFetchedRecommendations = true
                        isLoading = false
                        dismissLaunchScreenWithLog()
                    }
                } catch {
                    print("Failed to load recommendations: \(error)")
                    await MainActor.run {
                        isLoading = false
                        dismissLaunchScreenWithLog()
                    }
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

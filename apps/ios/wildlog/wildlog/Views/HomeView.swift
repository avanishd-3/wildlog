//
//  HomeView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import SwiftUI
import WildLogAPI

struct HomeView: View {
    
    @Binding var homeData: HomePageParkRecommendations

    var body: some View {
        NavigationStack {
            VStack {
                Text("Popular with your community")
                CarouselView(parks: homeData.communityParks)
                Spacer()
                Text("For you")
                CarouselView(parks: homeData.forYouParks)
            }
            .frame(maxWidth: .infinity)
            .task {
                await loadRecommendationsIfNeeded()
            }
        }
    }

    func loadRecommendationsIfNeeded() async {
        do {
            if homeData.communityParks.count > 0 && homeData.forYouParks.count > 0 {
                return
            }
            else { // Only need to fetch home page recommendations if they just signed up or logged in
                let result = try await apolloClient.fetch(query: GetHomePageRecommendationsQuery())
                debugPrint("Got result back from recommendations query")
                if let community = result.data?.getCommunityRecommendations {
                    homeData.communityParks = community.compactMap { Park(from: $0) }
                }
                if let forYou = result.data?.getForYouRecommendations {
                    homeData.forYouParks = forYou.compactMap { Park(from: $0) }
                }
            }
        } catch {
            print("Failed to load recommendations: \(error)")
        }
    }
}

#Preview {
    HomeView(homeData: .constant(HomePageParkRecommendations(from: [])))
}

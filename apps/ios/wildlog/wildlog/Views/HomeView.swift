//
//  HomeView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import SwiftUI
import WildLogAPI

struct HomeView: View {
    @State private var communityParks: [Park] = []
    @State private var forYouParks: [Park] = []

    var body: some View {
        NavigationStack {
            VStack {
                Text("Popular with your community")
                CarouselView(parks: communityParks)
                Spacer()
                Text("For you")
                CarouselView(parks: forYouParks)
            }
            .frame(maxWidth: .infinity)
            .task {
                await loadRecommendations()
            }
        }
    }

    func loadRecommendations() async {
        do {
            let result = try await apolloClient.fetch(query: GetHomePageRecommendationsQuery())
            debugPrint("Got result back from recommendations query")
            if let community = result.data?.getCommunityRecommendations {
                communityParks = community.compactMap { Park(from: $0) }
            }
            if let forYou = result.data?.getForYouRecommendations {
                forYouParks = forYou.compactMap { Park(from: $0) }
            }
        } catch {
            print("Failed to load recommendations: \(error)")
        }
    }
}

#Preview {
    HomeView()
}

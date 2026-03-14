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
                CarouselViewHorizontal(parks: homeData.communityParks)
                Spacer()
                Text("For you")
                CarouselViewHorizontal(parks: homeData.forYouParks)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    HomeView(homeData: .constant(HomePageParkRecommendations(from: [])))
}

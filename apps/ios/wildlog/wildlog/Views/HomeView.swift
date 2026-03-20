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
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {

                    // MARK: - Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Good \(timeOfDayGreeting())")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("Explore Parks")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // MARK: - Popular with Community
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(
                            title: "Popular with Friends",
                            subtitle: "What your community is visiting"
                        )
                        CarouselViewHorizontal(parks: homeData.communityParks)
                    }

                    // MARK: - For You
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(
                            title: "For You",
                            subtitle: "Picked based on your interests"
                        )
                        CarouselViewHorizontal(parks: homeData.forYouParks)
                    }

                    Spacer(minLength: 24)
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private func timeOfDayGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "morning"
        case 12..<17: return "afternoon"
        default: return "evening"
        }
    }
}

// MARK: - Section Header

private struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }
}

#Preview {
    HomeView(homeData: .constant(HomePageParkRecommendations(from: [])))
}

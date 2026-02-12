//
//  CarouselView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import SwiftUI

struct CarouselView: View {
    private let sampleTrips = [
        "acadia",
        "yosemite",
        "zion",
        "canyonlands",
        "glacier",
        "bryce"
    ]
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(sampleTrips, id: \.self) { trip in
                    if let park = ParkData.getPark(byImageName: trip) {
                        NavigationLink(destination: ParkDetailView(park: park)) {
                            Image(trip)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal, 10)
                        }
                    }
                }
            }
        }
        .scrollTargetBehavior(.paging) // Requires IOS 17
    }
}

#Preview {
    NavigationStack {
        CarouselView()
    }
}

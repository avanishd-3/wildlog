//
//  CarouselView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import SwiftUI
import Kingfisher

struct CarouselViewHorizontal: View {
    let parks: [Park]

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(parks, id: \.id) { park in
                    ParkNav(park: park, width: 150, height: 250)
                }
            }
        }
        // Move smoothly by default
        // Requires iOS 17
        .scrollTargetBehavior(.paging)
    }
}

#Preview {
    NavigationStack {
        CarouselViewHorizontal(parks: ParkData.sampleParks)
    }
}

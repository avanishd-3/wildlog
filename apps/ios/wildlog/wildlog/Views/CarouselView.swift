//
//  CarouselView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import SwiftUI

import SwiftUI

struct CarouselView: View {
    let parks: [Park]

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(parks, id: \.id) { park in
                    NavigationLink(destination: ParkDetailView(park: park)) {
                        Group {
                            if let imageName = park.imageName {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFill()
                            } else if let imageUrl = park.imageUrl, let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                Color.gray // fallback
                            }
                        }
                        .frame(width: 150, height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 10)
                    }
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
        CarouselView(parks: ParkData.sampleParks)
    }
}

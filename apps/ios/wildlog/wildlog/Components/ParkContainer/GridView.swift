//
//  CarouselViewVertical.swift
//  WildLog
//
//  Created by Avanish Davuluri on 3/13/26.
//

import SwiftUI

struct GridView: View {

    let parks: [Park]
    
    // Create adpative number of columns
    // Choose these numbers to get padding between columns
    // Only tested on iPhone 16 Pro simulator, so YMMV
    let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 160))
    ]

    var body: some View {
        ScrollView(.vertical) {
            // Spacing is how far the columns are spaced out horizontally
            LazyVGrid(columns: columns, spacing: 30) {
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
                        // Choose these numbers b/c they look good
                        .frame(width: 120, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 10)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        GridView(parks: ParkData.sampleParks)
    }
}

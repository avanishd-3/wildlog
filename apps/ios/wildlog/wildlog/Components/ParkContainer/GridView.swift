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
                    // Chose these width and height numbers b/c they look good
                    ParkNav(park: park, width: 120, height: 200)
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

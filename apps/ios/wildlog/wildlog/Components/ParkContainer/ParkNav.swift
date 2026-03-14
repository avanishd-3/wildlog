//
//  ParkNav.swift
//  WildLog
//
//  Created by Avanish Davuluri on 3/14/26.
//
// Needed to split this into its own component so the compiler can finish type-checking in time
// Also reduces multiple definitions of this

import SwiftUI

struct ParkNav: View {
    let park: Park
    let width: CGFloat
    let height: CGFloat
    
    
    var body: some View {
        NavigationLink(destination: ParkDetailView(park: park)) {
            Group {
                if let imageName = park.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                } else if let imageUrl = park.imageUrl, let url = URL(string: imageUrl) {
                    RemoteImage(url: url)
                } else {
                    Color(.systemGray) // fallback, shouldn't happen
                }
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 10)
        }
    }
}

#Preview {
    ParkNav(park: ParkData.sampleParks[0], width: 150, height: 250)
}

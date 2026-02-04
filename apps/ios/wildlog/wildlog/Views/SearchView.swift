//
//  SearchView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import SwiftUI
import MapKit

struct SearchView: View {
    // Center map on user location
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    
    var body: some View {
        Map(position: $position)
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                // Add all of these to get native experience
                MapUserLocationButton()
                MapScaleView()
                MapCompass()
                MapPitchToggle()
            }
    }
}

#Preview {
    SearchView()
}

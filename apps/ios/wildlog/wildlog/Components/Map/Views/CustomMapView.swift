//
//  CustomMapView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/4/26.
//

import SwiftUI
import WildLogAPI

struct CustomMapView: View {
    @Binding var selectedTab: Tabs
    
    // Controls which sheet is currently shown — passed down to the coordinator
    // so marker taps can trigger the park detail sheet from within UIKit
    @Binding var activeSheet: ActiveSheet?
    
    @Binding var filters: ParkFiltersInput?
    
    // The underlying MKMapView instance is passed through so SearchView can call
    // fetchParksForVisibleRegion directly when filters change from the sheet
    @Binding var mapView: CustomMkMapView

    var body: some View {
        VStack {
            MapViewRepresentable(
                selectedTab: $selectedTab,
                activeSheet: $activeSheet,
                filters: $filters,
                mapView: $mapView
            )
            .ignoresSafeArea()
            
            Spacer()
        }
    }
}

#Preview {
    CustomMapView(
        selectedTab: .constant(.home),
        activeSheet: .constant(.filters),
        filters: .constant(ParkFiltersInput()),
        mapView: .constant(CustomMkMapView())
    )
}

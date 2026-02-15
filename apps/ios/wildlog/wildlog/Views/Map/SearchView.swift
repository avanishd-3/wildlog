//
//  SearchView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import SwiftUI
import MapKit
import WildLogAPI

struct SearchView: View {
    @State private var position = MapCameraPosition.automatic
    
    @Binding var isSheetPresented: Bool
    @Binding var selectedTab: Tabs
    
    // Need to store filters up here so map can get them
    
    // Need to have map here, so the sheet can apply filters to the map
    @State private var mapView: CustomMkMapView = CustomMkMapView()
    @State private var filters: ParkFiltersInput?
    
    
    var body: some View {
        
        CustomMapView(selectedTab: $selectedTab, isSheetPresented: $isSheetPresented, filters: $filters, mapView: $mapView)
            .sheet(isPresented: $isSheetPresented) {
                let _ = debugPrint("Is sheet present: \(isSheetPresented)")
                SheetView(filters: $filters,
                          onFiltersChanged: {
                            fetchParksForVisibleRegion(mapView: mapView, filters: filters)
                })
            }
    }
}

#Preview {
    SearchView(isSheetPresented: .constant(true), selectedTab: .constant(.home))
}

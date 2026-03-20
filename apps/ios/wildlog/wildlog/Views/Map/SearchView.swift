//
//  SearchView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import SwiftUI
import MapKit
import WildLogAPI

// Controls which sheet is currently presented on the map screen.
enum ActiveSheet: Identifiable {
    case filters
    case parkDetail(Park)
    
    var id: String {
        switch self {
        case .filters: return "filters"
        case .parkDetail(let park): return park.id.uuidString
        }
    }
}

struct SearchView: View {
    @Binding var selectedTab: Tabs
    @State private var mapView: CustomMkMapView = CustomMkMapView()
    @State private var filters: ParkFiltersInput?
    @State private var activeSheet: ActiveSheet? = nil

    var body: some View {
        CustomMapView(
            selectedTab: $selectedTab,
            activeSheet: $activeSheet,
            filters: $filters,
            mapView: $mapView
        )
        // Show filter sheet when the user navigates to the search tab
        .onAppear {
            activeSheet = .filters
        }
        // Clear sheet when leaving the tab so it doesn't bleed into other tabs.
        .onDisappear {
            activeSheet = nil
        }
        // Single sheet modifier handles both filter and park detail presentation.
        .sheet(item: $activeSheet, onDismiss: {
            if selectedTab == .map && activeSheet == nil {
                activeSheet = .filters
            }
        }) { sheet in
            switch sheet {
            case .filters:
                SheetView(filters: $filters,
                          onFiltersChanged: {
                            fetchParksForVisibleRegion(mapView: mapView, filters: filters)
                })
            case .parkDetail(let park):
                NavigationStack {
                    ParkDetailView(park: park)
                }
            }
        }
    }
}

#Preview {
    SearchView(selectedTab: .constant(.map))
}

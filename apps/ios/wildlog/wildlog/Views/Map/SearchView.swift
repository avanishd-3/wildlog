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
    @State private var mapView: CustomMkMapView = CustomMkMapView()
    @State private var filters: ParkFiltersInput?
    
    func fetchParksForVisibleRegion(mapView: CustomMkMapView?, filters: ParkFiltersInput?) {
        debugPrint("Fetching parks from API")
        guard let mapView else { return }
        
        let region = mapView.region
        
        // Get coordinates for api
        let x_min = region.center.longitude - (region.span.longitudeDelta / 2)
        let x_max = region.center.longitude + (region.span.longitudeDelta / 2)
        let y_min = region.center.latitude - (region.span.latitudeDelta / 2)
        let y_max = region.center.latitude + (region.span.latitudeDelta / 2)
        
        Task {
                do {
                    let query = GetParksByBoundsQuery(filters: filters.map { .some($0) } ?? .none, x_max: x_max, x_min: x_min, y_max: y_max, y_min: y_min)
                    
                    let response = try await apolloClient.fetch(query: query)
                    let parks = response.data?.getParksByBounds?.compactMap { Park(from: $0) } ?? []
                    DispatchQueue.main.async {
                        mapView.removeAnnotations(mapView.annotations)
                        for park in parks {
                            mapView.addAnnotation(ParkAnnotation(park: park))
                        }
                    }
                } catch {
                    debugPrint(error.localizedDescription)
                }
            }
    }
    
    
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

//
//  FetchParksFromVisibleRegions.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/15/26.
//

import Foundation
import WildLogAPI

// The MapViewRepresentable needs to do this on init and for search this area button
// The sheet needs to do this for filters

// So functionality is extracted here

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
                let query = GetParkMapRecommendationsQuery(filters: filters.map { .some($0) } ?? .none, x_max: x_max, x_min: x_min, y_max: y_max, y_min: y_min)
                
                let response = try await apolloClient.fetch(query: query)
                let parks = response.data?.getParkMapRecommendations?.compactMap { Park(from: $0) } ?? []
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

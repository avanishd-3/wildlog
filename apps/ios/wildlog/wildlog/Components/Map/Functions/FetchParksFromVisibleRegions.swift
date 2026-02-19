//
//  FetchParksFromVisibleRegions.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/15/26.
//

import Foundation
import WildLogAPI
import MapKit


// The MapViewRepresentable needs to do this on init and for search this area button
// The sheet needs to do this for filters

// So functionality is extracted here

func fetchParksForVisibleRegion(mapView: CustomMkMapView?, filters: ParkFiltersInput?, searchButton: UIButton? = nil) {
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
                    
                    // Auto-pan if only 1 marker and not already visible
                    // Usually happens when search query matches trigram
                    // They shouldn't have to manually scroll to it
                    // The region should also not change if it's already visible
                    if parks.count == 1 {
                        let park = parks[0]
                        let coord = CLLocationCoordinate2D(latitude: park.latitude, longitude: park.longitude)
                        let currRegion = mapView.region
                        
                        // Check if marker is already is visisble
                        let minLat = currRegion.center.latitude - (currRegion.span.latitudeDelta / 2)
                        let maxLat = currRegion.center.latitude + (currRegion.span.latitudeDelta / 2)
                        let minLon = currRegion.center.longitude - (currRegion.span.longitudeDelta / 2)
                        let maxLon = currRegion.center.longitude + (currRegion.span.longitudeDelta / 2)
                        
                        let isMarkerVisible = (minLat...maxLat).contains(coord.latitude) && (minLon...maxLon).contains(coord.longitude)
                        
                        if !isMarkerVisible {
                            debugPrint("Setting new region b/c there is only one marker")
                            if let coordinator = mapView.delegate as? Coordinator { // Need coordinator to reset animation flag
                                debugPrint("Setting animating pan and zoom flag to true")
                                coordinator.isAnimatingPanAndZoom = true
                                _smoothPanAndZoom(to: coord, mapView: mapView, searchButton: searchButton, coordinator: coordinator)
                            }
                            else { // This should not happen, but just to be exhaustive
                                _smoothPanAndZoom(to: coord, mapView: mapView, searchButton: searchButton)
                            }
                            
                            
                        }
                        
                    }
                }
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
}


/**
    * Internal only function, do not use elsewhere
    * Smooth transition from user's current region to where the marker is, otherwise the map just pops in and out of existence (looks too jarring)
    * Hide search here button and reset animation flag when pan and zoom is over
 */
func _smoothPanAndZoom(to coordinate: CLLocationCoordinate2D,
                       mapView: MKMapView,
                       zoomSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1),
                       searchButton: UIButton? = nil,
                       coordinator: Coordinator? = nil,
) {
    
    // Disable user interaction and hide search here button
    mapView.isUserInteractionEnabled = false
    if let searchButton = searchButton {
        UIView.animate(withDuration: 0.2) {
            searchButton.alpha = 0
        }
    }
    
    let currentCenter = mapView.centerCoordinate
    let points = [currentCenter, coordinate]
    
    // Calculate a region that fits both points with padding
    let minLat = points.map { $0.latitude }.min() ?? coordinate.latitude
    let maxLat = points.map { $0.latitude }.max() ?? coordinate.latitude
    let minLon = points.map { $0.longitude }.min() ?? coordinate.longitude
    let maxLon = points.map { $0.longitude }.max() ?? coordinate.longitude
    
    // Add some padding (make sure markers are not cut off)
    let latPadding = abs(maxLat - minLat) * 0.5 + 0.05
    let lonPadding = abs(maxLon - minLon) * 0.5 + 0.05
    
    let midLat = (minLat + maxLat) / 2
    let midLon = (minLon + maxLon) / 2
    let zoomOutSpan = MKCoordinateSpan(latitudeDelta: abs(maxLat - minLat) + latPadding, longitudeDelta: abs(maxLon - minLon) + lonPadding)
    
    let zoomOutRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: midLat, longitude: midLon), span: zoomOutSpan)
    
    // 1. Zoom out to fit both points
    mapView.setRegion(zoomOutRegion, animated: true)
    
    // 2. After zoom out animation, pan to the new center
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
        
        let panRegion = MKCoordinateRegion(center: coordinate, span: zoomOutSpan)
        mapView.setRegion(panRegion, animated: true) // I think this looks better than changing center
        
        // 3. After pan, zoom in to desired span
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { // More jarring if set to lower time
            let zoomInRegion = MKCoordinateRegion(center: coordinate, span: zoomSpan)
            mapView.setRegion(zoomInRegion, animated: true)
            
            // Reset user interaction
            mapView.isUserInteractionEnabled = true
            
            // Keep search here button hidden the whole time
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                debugPrint("Setting animating pan and zoom flag to false")
                coordinator?.isAnimatingPanAndZoom = false
            }
        }
    }
}

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
                let oldParksAnnotations : [ParkAnnotation] = await mapView.annotations.compactMap { $0 as? ParkAnnotation }
                let oldParks = oldParksAnnotations.map(\.park)
                
                let newParks = response.data?.getParkMapRecommendations?.compactMap { Park(from: $0) } ?? []
                let newParkAnnotations: [ParkAnnotation] = newParks.map(ParkAnnotation.init) // For pan and zoom coordinate check
                
                // Do not remove an annotation if it is also in the new park set
                // So park marker doesn't pop out and in
                let parksToAdd = Array(Set(newParks).subtracting(Set(oldParks)))
                let parksToRemove = Array(Set(oldParks).subtracting(Set(newParks)))
                
                debugPrint("Removing: \(parksToRemove.count) markers")
                debugPrint("Adding: \(parksToAdd.count) markers")
                
                
                DispatchQueue.main.async {
                    for park in parksToRemove {
                        let oldParksAnnotationToRemove = oldParksAnnotations.first(where: { $0.park.id == park.id })
                        
                        // Optional should never happen, it's just to make Swift happy
                        // You need to pass in the old annotation or it won't actually remove it
                        mapView.removeAnnotation(oldParksAnnotationToRemove ?? ParkAnnotation(park: park))
                    }

                    for park in parksToAdd {
                        mapView.addAnnotation(ParkAnnotation(park: park))
                    }
                    
                    // Auto-pan if any of the markers are not visible
                    // Usually happens when search query matches trigram
                    // They shouldn't have to manually scroll to it
                    // The region should also not change they're already visible
                    let anyMarkerInvisible = parksToAdd.contains(where: {
                        let coord = CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                        let currRegion = mapView.region
                        
                        let minLat = currRegion.center.latitude - (currRegion.span.latitudeDelta / 2)
                        let maxLat = currRegion.center.latitude + (currRegion.span.latitudeDelta / 2)
                        let minLon = currRegion.center.longitude - (currRegion.span.longitudeDelta / 2)
                        let maxLon = currRegion.center.longitude + (currRegion.span.longitudeDelta / 2)
                        
                        let isMarkerInvisible = (coord.latitude < minLat || coord.latitude > maxLat || coord.longitude < minLon || coord.longitude > maxLon)
                        return isMarkerInvisible
                    })
                    
                    if anyMarkerInvisible {
                        debugPrint("Setting new region b/c some markers are invisible")
                        let coordinates = newParkAnnotations.map { $0.coordinate }
                        
                        
                        if let coordinator = mapView.delegate as? Coordinator { // Need coordinator to reset animation flag
                            debugPrint("Setting animating pan and zoom flag to true")
                            coordinator.isAnimatingPanAndZoom = true
                            _smoothPanAndZoom(with: coordinates, mapView: mapView, searchButton: searchButton, coordinator: coordinator)
                        }
                        else { // This should not happen, but just to be exhaustive
                            _smoothPanAndZoom(with: coordinates, mapView: mapView, searchButton: searchButton)
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
func _smoothPanAndZoom(with coordinates: [CLLocationCoordinate2D],
                       mapView: MKMapView,
                       searchButton: UIButton? = nil,
                       coordinator: Coordinator? = nil,
) {
    
    if (coordinates.isEmpty) { // Shouldn't happen, ignore this stuff if it does
        return
    }
    
    // Disable user interaction and hide search here button
    mapView.isUserInteractionEnabled = false
    if let searchButton = searchButton {
        UIView.animate(withDuration: 0.2) {
            searchButton.alpha = 0
        }
    }
    
    // Calculate a region that fits all the points (user location + new markers) with padding
    
    let currentCenter = mapView.centerCoordinate
    let points = coordinates + [currentCenter]
    
    var minLat: Double = coordinates[0].latitude;
    var maxLat: Double = coordinates[0].latitude;
    var minLon: Double = coordinates[0].longitude;
    var maxLon: Double = coordinates[0].longitude;
    
    for point in points {
        let lat = point.latitude
        let lon = point.longitude
        
        if lat < minLat { minLat = lat }
        if lat > maxLat { maxLat = lat }
        if lon < minLon { minLon = lon }
        if lon > maxLon { maxLon = lon }
    }
    
    // Add some padding (make sure markers are not cut off)
    let latPadding = abs(maxLat - minLat) * 0.1
    let lonPadding = abs(maxLon - minLon) * 0.1
    
    let zoomOutSpan = MKCoordinateSpan(latitudeDelta: abs(maxLat - minLat) + latPadding, longitudeDelta: abs(maxLon - minLon) + lonPadding)
    
    // Center on average of coordinates
    let midLat = coordinates.map((\.latitude)).reduce(0, +) / Double(coordinates.count)
    let midLon = coordinates.map((\.longitude)).reduce(0, +) / Double(coordinates.count)
    
    let newCenterCoordinate = CLLocationCoordinate2D(latitude: midLat, longitude: midLon)
    
    let zoomOutRegion = MKCoordinateRegion(center: newCenterCoordinate, span: zoomOutSpan)
    
    // 1. Zoom out to fit all points
    mapView.setRegion(zoomOutRegion, animated: true)
    
    // 2. After zoom out animation, pan to the new center
    // I think just keeping a zoomed out view gives the park(s) a sense of place relative to the user
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
        
        let zoomOutSpanLatDelta = zoomOutSpan.latitudeDelta
        let zoomOutSpanLonDelta = zoomOutSpan.longitudeDelta
        
        // Zooming in a little compared to step 1 looks better
        let newRegion = MKCoordinateRegion(center: newCenterCoordinate, span: MKCoordinateSpan(latitudeDelta: zoomOutSpanLatDelta * 0.9, longitudeDelta: zoomOutSpanLonDelta * 0.9))
        mapView.setRegion(newRegion, animated: true) // I think this looks better than changing center
        
        // Reset user interaction
        mapView.isUserInteractionEnabled = true
        
        // Keep search here button hidden the whole time
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            debugPrint("Setting animating pan and zoom flag to false")
            coordinator?.isAnimatingPanAndZoom = false
        }
    }
}

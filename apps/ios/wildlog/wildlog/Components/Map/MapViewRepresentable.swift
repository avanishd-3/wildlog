//
//  MapViewRepresentable.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/4/26.
//

import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        // Map style
        let config = MKStandardMapConfiguration()
        config.elevationStyle = .realistic
        mapView.preferredConfiguration = config
        
        // User location
        // Equivalent to UserAnnotation()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        // Native controls
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.isPitchEnabled = true
        mapView.isRotateEnabled = true
        mapView.isZoomEnabled = true
        
        // User tracking
        // Equivalent to MapUserLocationButton()
        let trackingButton = MKUserTrackingButton(mapView: mapView)
        trackingButton.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(trackingButton)
        
        // Put layout on top right
        // TODO: Make this look more native and not overlap content
        NSLayoutConstraint.activate([
            trackingButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
            trackingButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 8)
        ])
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        // Update map configuration if needed
    }
    
    static func dismantleUIView(_ uiView: MKMapView, coordinator: Coordinator) {
        uiView.removeFromSuperview()
    }
}

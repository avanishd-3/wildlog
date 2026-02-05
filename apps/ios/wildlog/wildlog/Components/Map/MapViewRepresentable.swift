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
        
        // Blur button so text doesn't make it hard to see
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.layer.cornerRadius = 10
        blur.clipsToBounds = true
        
        blur.contentView.addSubview(trackingButton)
        
        mapView.addSubview(blur)
        
        // Put layout on top right
        // TODO: Make this look more native and not overlap content
        NSLayoutConstraint.activate([
            blur.widthAnchor.constraint(equalToConstant: 44),
            blur.heightAnchor.constraint(equalToConstant: 44),
            
            blur.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
            blur.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -16),
            
            trackingButton.centerXAnchor.constraint(equalTo: blur.centerXAnchor),
            trackingButton.centerYAnchor.constraint(equalTo: blur.centerYAnchor),
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

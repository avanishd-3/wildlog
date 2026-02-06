//
//  MapViewRepresentable.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/4/26.
//


// See: https://stackoverflow.com/questions/79502649/swiftui-tabbar-appearance-doesnt-work-in-only-those-views-which-have-map
// We need to customize the map using the old-school approach b/c we need custom tab color and will eventually add filter buttons

import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    // UIViewRepresentable is a way to put UI Kit views into the Swift UI view hierarchy
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = CustomMkMapView()
        
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
        
        // TODO: Make buttons look like Apple Maps
        // TODO: 2D to 3D animation like Apple Maps
        // Equivalent to MapUserLocationButton()
        let trackingButton = MKUserTrackingButton(mapView: mapView)
        trackingButton.translatesAutoresizingMaskIntoConstraints = false
        trackingButton.tintColor = .secondarySystemBackground
        trackingButton.backgroundColor = .clear
        trackingButton.accessibilityLabel = "User Location"
        
        // Blur button so text doesn't make it hard to see
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.layer.cornerRadius = 10
        blur.clipsToBounds = true
        blur.backgroundColor = .clear
        
        blur.contentView.addSubview(trackingButton)
        
        mapView.addSubview(blur)
        
        // Pitch control button (below tracking button)
        // Allows user to toggle b/n 2D and 3D
        // Use text like Apple Maps
        let pitchButton = UIButton(type: .system)
        pitchButton.translatesAutoresizingMaskIntoConstraints = false
        let initialTitle = mapView.camera.pitch == 0 ? "2D" : "3D"
        pitchButton.setTitle(initialTitle, for: .normal) // Set initial title based on actual pitch
        pitchButton.setTitleColor(UIColor.label, for: .normal)
        pitchButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        pitchButton.backgroundColor = .clear // Weird stuff happens without this
        pitchButton.accessibilityLabel = "Toggle 3D"
        
        let pitchBlur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        pitchBlur.translatesAutoresizingMaskIntoConstraints = false
        pitchBlur.layer.cornerRadius = 10
        pitchBlur.clipsToBounds = true
        pitchBlur.backgroundColor = .clear
        
        pitchBlur.contentView.addSubview(pitchButton)
        
        mapView.addSubview(pitchBlur)
        
        // Put layout on top right
        // TODO: Make this look more native and not overlap content
        NSLayoutConstraint.activate([
            // tracking blur
            blur.widthAnchor.constraint(equalToConstant: 44),
            blur.heightAnchor.constraint(equalToConstant: 44),
            
            blur.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
            blur.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 64),
            
            trackingButton.centerXAnchor.constraint(equalTo: blur.centerXAnchor),
            trackingButton.centerYAnchor.constraint(equalTo: blur.centerYAnchor),
            
            // pitch blur (below tracking button)
            
            pitchBlur.widthAnchor.constraint(equalToConstant: 44),
            pitchBlur.heightAnchor.constraint(equalToConstant: 44),
            
            pitchBlur.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -16),
            pitchBlur.topAnchor.constraint(equalTo: blur.bottomAnchor, constant: 16),
            
            pitchButton.centerXAnchor.constraint(equalTo: pitchBlur.centerXAnchor),
            pitchButton.centerYAnchor.constraint(equalTo: pitchBlur.centerYAnchor),
        ])
        
        // Coordinate lookup for pitch action
        // So button actually works
        let coordinator = context.coordinator
        coordinator.mapView = mapView
        coordinator.pitchButton = pitchButton
        pitchButton.addTarget(coordinator, action: #selector(Coordinator.togglePitch(_:)), for: .touchUpInside)
        
        
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        // Update map configuration if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // This is for communicating marker changes to map view
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        weak var mapView: MKMapView? // Map view can be de-allocated if no actual var points to it
        weak var pitchButton: UIButton?
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        @objc func togglePitch(_ sender: UIButton) {
            // Toggle b/n 2D (pitch = 0) and 3D (pitch = 60)
            guard let mapView = mapView else { return }
            let currentPitch = mapView.camera.pitch
            let newPitch: CGFloat = currentPitch == 0 ? 60 : 0
            let camera = mapView.camera
            camera.pitch = newPitch
            mapView.setCamera(camera, animated: true)
            
            // Update button text like Apple Maps
            // Show text 2D when in 3D and text 3D when in 2D
            DispatchQueue.main.async {
                [weak self] in
                let title = newPitch == 0 ? "3D" : "2D"
                self?.pitchButton?.setTitle(title, for: .normal)
            }
            
            
        }
    }
    
    static func dismantleUIView(_ uiView: MKMapView, coordinator: Coordinator) {
        uiView.removeFromSuperview()
    }
}

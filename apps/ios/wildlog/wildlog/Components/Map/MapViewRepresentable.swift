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
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        // ---- Map style -----
        let config = MKStandardMapConfiguration()
        config.elevationStyle = .realistic
        mapView.preferredConfiguration = config
        
        // ---- Native controls ----
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.isPitchEnabled = true
        mapView.isRotateEnabled = true
        mapView.isZoomEnabled = true
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none // Default to none like Apple Maps

        // ---- Location button ----
        let locationContainer = MapsControlContainer()
        let locationButton = CustomUserTrackingButton()

        locationContainer.contentView.addSubview(locationButton)
        mapView.addSubview(locationContainer)

        // ---- Pitch button ----
        let pitchContainer = MapsControlContainer()
        let pitchButton = CustomPitchButton()

        pitchContainer.contentView.addSubview(pitchButton)
        mapView.addSubview(pitchContainer)

        // ---- Layout (Apple Maps spacing) ----
        NSLayoutConstraint.activate([
            locationContainer.topAnchor.constraint(
                equalTo: mapView.safeAreaLayoutGuide.topAnchor,
                constant: 12
            ),
            locationContainer.trailingAnchor.constraint(
                equalTo: mapView.trailingAnchor,
                constant: -12
            ),
            locationContainer.widthAnchor.constraint(equalToConstant: 44),
            locationContainer.heightAnchor.constraint(equalToConstant: 44),

            pitchContainer.topAnchor.constraint(
                equalTo: locationContainer.bottomAnchor,
                constant: 12
            ),
            pitchContainer.trailingAnchor.constraint(
                equalTo: locationContainer.trailingAnchor
            ),
            pitchContainer.widthAnchor.constraint(equalToConstant: 44),
            pitchContainer.heightAnchor.constraint(equalToConstant: 44),

            locationButton.centerXAnchor.constraint(equalTo: locationContainer.centerXAnchor),
            locationButton.centerYAnchor.constraint(equalTo: locationContainer.centerYAnchor),

            pitchButton.centerXAnchor.constraint(equalTo: pitchContainer.centerXAnchor),
            pitchButton.centerYAnchor.constraint(equalTo: pitchContainer.centerYAnchor),
        ])

        // ---- Wiring (so buttons actually do stuff) ----
        context.coordinator.mapView = mapView
        context.coordinator.locationButton = locationButton
        context.coordinator.pitchButton = pitchButton

        locationButton.addTarget(
            context.coordinator,
            action: #selector(Coordinator.didTapLocation),
            for: .touchUpInside
        )

        pitchButton.addTarget(
            context.coordinator,
            action: #selector(Coordinator.didTapPitch),
            for: .touchUpInside
        )

        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        // Update map configuration if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

// This is for communicating marker changes to map view
final class Coordinator: NSObject, MKMapViewDelegate {

    weak var mapView: MKMapView?
    weak var locationButton: CustomUserTrackingButton?
    weak var pitchButton: CustomPitchButton?
    
    // Track whether we've centered on the user's location once
    private var hasCenteredOnUser = false

    @objc func didTapLocation() {
        guard let mapView else { return }
        
        debugPrint("Entering did tap location")

        let next: MKUserTrackingMode = switch mapView.userTrackingMode {
        case .none: .follow
        case .follow: .followWithHeading
        default: .none
        }

        debugPrint("Setting user tracking mode to: \(next)")
        mapView.setUserTrackingMode(next, animated: true)
    }

    @objc func didTapPitch() {
        debugPrint("In did tap pitch")
        guard let mapView else { return }
        
        // Without using the old distance, the pitch change would zoom out the view
        // TODO: Apple Maps animation when moving between 2D and 3D (on text as well)

        let camera = mapView.camera
        let oldDistance = camera.centerCoordinateDistance
        debugPrint("Old pitch: \(camera.pitch)")
        
        
        let newPitch = camera.pitch == 0.0 ? 60.0 : 0.0
        debugPrint("New pitch: \(newPitch)")
        camera.pitch = newPitch
        camera.centerCoordinateDistance = oldDistance
        mapView.setCamera(camera, animated: true)

        // Camera pitch changes async
        // so need to use the newPitch value
        pitchButton?.update(for: newPitch)
    }

    func mapView(_ mapView: MKMapView,
                 didChange mode: MKUserTrackingMode,
                 animated: Bool) {
        locationButton?.update(for: mode)
    }
    
    // Initially center the map on the user
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard !hasCenteredOnUser, let coord = userLocation.location?.coordinate else { return }
        hasCenteredOnUser = true

        // Span values are what Apple uses
        // So clicking the user tracking button doesn't change region view
        let region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.024721442510596603, longitudeDelta: 0.01724951020932508))
        mapView.setRegion(region, animated: true)
    }
}

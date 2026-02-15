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
import Apollo
import WildLogAPI

struct MapViewRepresentable: UIViewRepresentable {
    // UIViewRepresentable is a way to put UI Kit views into the Swift UI view hierarchy
    
    @Binding var selectedTab: Tabs
    @Binding var isSheetPresented: Bool
    
    // Filter bindings
    @Binding var filters: ParkFiltersInput?
    
    @Binding var mapView: CustomMkMapView
    
    func makeUIView(context: Context) -> MKMapView {
//        let mapView = CustomMkMapView()
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
        
        // ---- Register custom marker ----
        mapView.register(CustomMarker.self, forAnnotationViewWithReuseIdentifier: CustomMarker.identifier)

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
        
        // ---- Back button ----
        let backContainer = MapsControlContainer()
        let backButton = CustomBackButton()
        
        backContainer.contentView.addSubview(backButton)
        mapView.addSubview(backContainer)
        
        // ---- Search this area button ----
        
        // No container b/c want different styling for this
        let searchButton = SearchThisAreaButton()
        mapView.addSubview(searchButton)
        

        // ---- Layout (Apple Maps spacing) ----
        NSLayoutConstraint.activate([
            
            // Location and pitch button on top right
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
            
            // Back button on top left
            backContainer.topAnchor.constraint(
                equalTo: mapView.safeAreaLayoutGuide.topAnchor,
                constant: 12
            ),
            backContainer.leadingAnchor.constraint(
                equalTo: mapView.leadingAnchor,
                constant: 12
            ),
            
            backContainer.widthAnchor.constraint(equalToConstant: 44),
            backContainer.heightAnchor.constraint(equalToConstant: 44),
            
            backButton.centerXAnchor.constraint(equalTo: backContainer.centerXAnchor),
            backButton.centerYAnchor.constraint(equalTo: backContainer.centerYAnchor),
            
            // Search area button bottom middle (large constant to be above sheet)
            // TODO: Maybe push button up when sheet moves up
            searchButton.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            searchButton.bottomAnchor.constraint(
                equalTo: mapView.safeAreaLayoutGuide.bottomAnchor,
                constant: -160
            ),
        ])

        // ---- Wiring (so buttons actually do stuff) ----
        context.coordinator.mapView = mapView
        context.coordinator.locationButton = locationButton
        context.coordinator.pitchButton = pitchButton
        context.coordinator.backButton = backButton
        context.coordinator.searchButton = searchButton

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
        
        backButton.addTarget(
            context.coordinator,
            action: #selector(Coordinator.didTapBackButton),
            for: .touchUpInside
        )
        
        searchButton.addTarget(
            context.coordinator,
            action: #selector(Coordinator.didTapSearchThisArea),
            for: .touchUpInside
        )
        
        // Fetch parks for initial region
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            context.coordinator.fetchParks()
        }

        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            selectedTab: $selectedTab,
            isSheetPresented: $isSheetPresented,
            filters: $filters
        )
    }
}

// This is for communicating marker changes to map view
final class Coordinator: NSObject, MKMapViewDelegate {
    
    init(
        selectedTab: Binding<Tabs>,
        isSheetPresented: Binding<Bool>,
        mapView: CustomMkMapView? = nil,
        locationButton: CustomUserTrackingButton? = nil,
        pitchButton: CustomPitchButton? = nil,
        backButton: CustomBackButton? = nil,
        hasCenteredOnUser: Bool = false,
        searchButton: SearchThisAreaButton? = nil,
        filters: Binding<ParkFiltersInput?>
    ) {
            
        self.selectedTab = selectedTab
        self.isSheetPresented = isSheetPresented
        self.mapView = mapView
        self.locationButton = locationButton
        self.pitchButton = pitchButton
        self.backButton = backButton
        self.hasCenteredOnUser = hasCenteredOnUser
        self.searchButton = searchButton
        self.filters = filters
    }
    
    var selectedTab: Binding<Tabs>
    var isSheetPresented: Binding<Bool>
    var filters: Binding<ParkFiltersInput?>
    
    /* Weak references */
    weak var mapView: CustomMkMapView?
    weak var locationButton: CustomUserTrackingButton?
    weak var pitchButton: CustomPitchButton?
    weak var backButton: CustomBackButton?
    weak var searchButton: SearchThisAreaButton?
    
    // Tracking variables
    private var hasCenteredOnUser = false
    
    // Region changes twice on first load, so need 2 flags
    private var initializingMapOne = true
    private var initializingMapTwo = true

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
    
    @objc func didTapBackButton() {
        debugPrint("In did tap back button")
        self.selectedTab.wrappedValue = .home
        self.isSheetPresented.wrappedValue = false
    }
    
    // Handle when user clicks the search this area button
    @objc func didTapSearchThisArea() {
        debugPrint("In did tap search this area button")
        fetchParks()
        UIView.animate(withDuration: 0.2) {
            self.searchButton?.alpha = 0 // Hide search button
        }
    }
    
    func fetchParks() {
        fetchParksForVisibleRegion(mapView: mapView, filters: filters.wrappedValue)
    }
    
    

    func mapView(_ mapView: MKMapView,
                 didChange mode: MKUserTrackingMode,
                 animated: Bool) {
        locationButton?.update(for: mode)
    }
    
    //Show the search this area button when the region changes (pan or zoom)
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        debugPrint("Region did change")
        
        // Hide button when map is first shown (region changes twice on first load)
        
        if (!initializingMapOne && !initializingMapTwo) {
            UIView.animate(withDuration: 0.2) {
                self.searchButton?.alpha = 1
            }
        }
        else {
            debugPrint("Initializing map")
            if initializingMapOne {
                initializingMapOne = false
            }
            else {
                initializingMapTwo = false
            }
        }
        
    }
    
    // Use custom marker for parks
    // See: https://www.hackingwithswift.com/read/16/3/annotations-and-accessory-views-mkpinannotationview
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        
        // TODO: When user clicks on marker, they should be redirected to the ParkView for that park
        
        // Do not customizer user location
        guard !(annotation is MKUserLocation) else { return nil }
        
        guard let parkAnnotation = annotation as? ParkAnnotation else {
            debugPrint("Annotation not a ParkAnnotation")
            return nil }
        
        // Does not show custom annotation if you let annotationView equal this
        // But I think dequeue is important, so I'll leave it in
        mapView.dequeueReusableAnnotationView(withIdentifier: CustomMarker.identifier, for: parkAnnotation)
        
        let annotationView = CustomMarker(annotation: parkAnnotation, reuseIdentifier: CustomMarker.identifier)
        
        annotationView.annotation = parkAnnotation
        return annotationView
    }
    
    // Initially center the map on the user
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard !hasCenteredOnUser, let coord = userLocation.location?.coordinate else { return }
        hasCenteredOnUser = true
        
        // Have initial region be w/in 25 miles of user location
        // Otherwise starting off w/ no parks recommended is common
        //
        
        let miles: CLLocationDistance = 25
        let regionRadius: CLLocationDistance = miles * 1609.344 // B/c 1 degree latitude is ~69 miles
        let region = MKCoordinateRegion(center: coord, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(region, animated: true)
    }
}

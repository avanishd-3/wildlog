//
//  ParkAnnotation.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/14/26.
//

import Foundation
import MapKit

final class ParkAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    
    // Subtitles look weird and Apple Maps doesn't use them
    
    // Title is from MkAnnotation
    // Error if not optional
    let title: String?
    
    // Non-inherited variables
    // Storing parks so can use them later
    let park: Park
    
    init(park: Park) {
        self.coordinate = CLLocationCoordinate2D(latitude: park.latitude, longitude: park.longitude)
        self.title = park.name
        self.park = park
    }
}

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
    
    // Error if not optional
    let title: String?
    
    init(park: Park) {
        self.coordinate = CLLocationCoordinate2D(latitude: park.latitude, longitude: park.longitude)
        self.title = park.name
    }
}

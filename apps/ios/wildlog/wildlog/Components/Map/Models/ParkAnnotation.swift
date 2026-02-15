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
    
    // Error if these 2 are not optional
    let title: String?
    let subtitle: String?
    
    init(park: Park) {
        self.coordinate = CLLocationCoordinate2D(latitude: park.latitude, longitude: park.longitude)
        self.title = park.name
        self.subtitle = park.designation
    }
}

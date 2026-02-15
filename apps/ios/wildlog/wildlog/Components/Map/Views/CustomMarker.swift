//
//  CustomMarker.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/14/26.
//

import Foundation
import UIKit
import MapKit

final class CustomMarker: MKMarkerAnnotationView {
    static let identifier = "ParkMarker" // So MapKit can track the type of marker being removed and added
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.markerTintColor = .systemGreen
        self.glyphTintColor = .white
        self.displayPriority = .required
        self.animatesWhenAdded = true
        
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        
        self.glyphImage = UIImage(systemName: "tree.fill", withConfiguration: config)
    }
}

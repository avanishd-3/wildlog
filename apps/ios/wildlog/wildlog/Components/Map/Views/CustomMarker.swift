//
//  CustomMarker.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/14/26.
//

import Foundation
import UIKit
import MapKit

final class CustomMarker: MKAnnotationView {
    static let identifier = "CustomMarker"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        let image = UIImage(systemName: "tree.fill", withConfiguration: config)?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        self.image = image
        self.centerOffset = CGPoint(x: 0, y: -14)
    }
}

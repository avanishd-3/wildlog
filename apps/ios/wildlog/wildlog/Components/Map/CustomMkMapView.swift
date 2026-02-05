//
//  CustomMkMapView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/5/26.
//

import MapKit


// See: https://stackoverflow.com/questions/48343381/how-to-reposition-compass-of-mkmapview
// This sub class just exists to have the compass be in the same position as Apple Maps

class CustomMkMapView: MKMapView {
    
    // Initial value not calculated until property accessed for 1st time
    lazy var comp: MKCompassButton = {
        let v = MKCompassButton(mapView: self)
        v.isUserInteractionEnabled = true
        addSubview(v)
        return v
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        showsCompass = false // This name is bad, it actually refers to the defaultCompass
        comp.frame = CGRect(
                    origin: CGPoint(x: bounds.width - 64 - comp.bounds.size.width,
                                    y: 49),
                    size: comp.bounds.size)
    }
}

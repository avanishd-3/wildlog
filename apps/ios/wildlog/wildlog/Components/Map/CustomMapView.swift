//
//  CustomMapView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/4/26.
//

import SwiftUI

struct CustomMapView: View {
    var body: some View {
        VStack {
            MapViewRepresentable()
                .ignoresSafeArea()
            
            Spacer()
        }
    }
}

//
//  SearchView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @State private var position = MapCameraPosition.automatic
    @State private var isSheetPresented: Bool = true
    
    var body: some View {
        CustomMapView()
            .ignoresSafeArea()
            .sheet(isPresented: $isSheetPresented) {
                SheetView()
            }
    }
}

#Preview {
    SearchView()
}

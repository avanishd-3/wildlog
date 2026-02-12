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
    
    @Binding var isSheetPresented: Bool
    @Binding var selectedTab: Tabs
    
    
    var body: some View {
        
        CustomMapView(selectedTab: $selectedTab, isSheetPresented: $isSheetPresented)
            .sheet(isPresented: $isSheetPresented) {
                let _ = debugPrint("Is sheet present: \(isSheetPresented)")
                SheetView()
            }
    }
}

#Preview {
    SearchView(isSheetPresented: .constant(true), selectedTab: .constant(.home))
}

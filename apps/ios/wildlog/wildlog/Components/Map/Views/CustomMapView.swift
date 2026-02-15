//
//  CustomMapView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/4/26.
//

import SwiftUI
import WildLogAPI

struct CustomMapView: View {
    @Binding var selectedTab: Tabs
    @Binding var isSheetPresented: Bool
    
    @Binding var filters: ParkFiltersInput?
    @Binding var mapView: CustomMkMapView
    
    var body: some View {
        VStack {
            MapViewRepresentable(selectedTab: $selectedTab, isSheetPresented: $isSheetPresented,
                filters: $filters, mapView: $mapView
            )
                .ignoresSafeArea()
            
            Spacer()
        }
    }
}

//#Preview {
//    CustomMapView(selectedTab: .constant(.home), isSheetPresented: .constant(false))
//}

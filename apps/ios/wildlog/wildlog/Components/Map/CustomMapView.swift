//
//  CustomMapView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/4/26.
//

import SwiftUI

struct CustomMapView: View {
    @Binding var selectedTab: Tabs
    @Binding var isSheetPresented: Bool
    var body: some View {
        VStack {
            MapViewRepresentable(selectedTab: $selectedTab, isSheetPresented: $isSheetPresented)
                .ignoresSafeArea()
            
            Spacer()
        }
    }
}

#Preview {
    CustomMapView(selectedTab: .constant(.home), isSheetPresented: .constant(false))
}

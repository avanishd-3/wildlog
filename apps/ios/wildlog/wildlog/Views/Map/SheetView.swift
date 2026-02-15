//
//  SheetView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/5/26.
//

// See: https://www.polpiella.dev/mapkit-and-swiftui-searchable-map
// It's not exactly this because some stuff is deprecated but it's close

import SwiftUI
import MapKit
import WildLogAPI

struct SheetView: View {
    @State private var search: String = ""
    
    // Filter options
    let parkTypes = ["National", "State"]
    let parkCosts = ["Free", "$", "$$"]
    let maxDistances = ["25", "50", "75", "100"]
    
    @State private var selectedParkType: String?
    @State private var selectedParkCost: String?
    @State private var selectedMaxDistance: String?
    
    // Closure to notify parent of filter changes
    var onFiltersChanged: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                // I think disabling autocorrect makes it less annoying
                // to type rare words
                TextField("Search", text: $search)
                    .autocorrectionDisabled()
            }
            .modifier(TextFieldGrayBackgroundColor())
            
            // Filters
            VStack(alignment: .leading, spacing: 8) {
                FilterChips(
                    title: "Type",
                    options: parkTypes,
                    selected: selectedParkType,
                    onSelect: { type in
                        selectedParkType = (selectedParkType == type) ? nil : type
                        onFiltersChanged?()
                    }
                )
                FilterChips(
                    title: "Cost",
                    options: parkCosts,
                    selected: selectedParkCost,
                    onSelect: { cost in
                        selectedParkCost = (selectedParkCost == cost) ? nil : cost
                        onFiltersChanged?()
                    }
                )
                FilterChips(
                    title: "Max Distance (mi)",
                    options: maxDistances,
                    selected: selectedMaxDistance,
                    onSelect: { dist in
                        selectedMaxDistance = (selectedMaxDistance == dist) ? nil : dist
                        onFiltersChanged?()
                    }
                )
            }
                        
                        Spacer()
            
            
        }
        .padding()
        // Do not allow user to dismiss sheet
        // Since Swift UI maintains views, they cannot bring it back up
        // Have a back button in the map instead
        // I think this is fine UX, but maybe having search as a tab is not the best option
        // TODO: See if memory is an issue w/ keeping the map and how to handle it
        .interactiveDismissDisabled(true)
        .presentationDetents([.height(200), .large]) // Sheet view will auto-resize when user types in search
        .presentationBackground(.regularMaterial) // Apple Maps-like blur for sheet
        // User can interact with map view behind sheet
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
    }
}

struct TextFieldGrayBackgroundColor: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8.0, style: .continuous))
            .foregroundColor(.primary)
    }
}

#Preview {
    SheetView()
}

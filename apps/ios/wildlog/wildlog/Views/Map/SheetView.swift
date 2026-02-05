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

struct SheetView: View {
    @State private var search: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                // I think disabling autocorrect makes it less annoying
                // to type rare words
                TextField("Search", text: $search)
                    .autocorrectionDisabled()
            }
            .modifier(TextFieldGrayBackgroundColor())
            
            Spacer()
            
            
        }
        .padding()
        // Allow user to dismiss sheet to go to other tabs
        // I think this is fine UX, but maybe having search as a tab is not the best option
        // TODO: Look at Beli to see how they handle it
        .interactiveDismissDisabled(false)
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

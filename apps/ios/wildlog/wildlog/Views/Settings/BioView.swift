//
//  BioView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/3/26.
//

import SwiftUI

struct BioView: View {
    @Binding var bio: String
    @Environment(\.dismiss) private var dimiss // To close view
    @FocusState private var isFocused: Bool
    
    
    var body: some View {
        TextEditor(text: $bio)
            .padding(16) // So text not at edge of screen
            .focused($isFocused)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Update bio")
            .navigationBarTitleDisplayMode(.inline) // Bio in center
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // TODO: Update DB on save
                        isFocused = false
                        dimiss()
                    }
                    .tint(.green) // Save should be green
                }
            }
            // toolbarRole is iOS 16+
            .toolbarRole(.editor) // Just display back arrow, no text
        
            .onAppear {
                // Ensure text editor exists before being focused on
                Task { @MainActor in
                    isFocused = true
                }
            }
    }
}

#Preview {
    BioView(bio: .constant(""))
}

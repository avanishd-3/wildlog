//
//  SettingsView.swift
//  WildLog
//
//  Created by Derek Cao on 2/4/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Account")
            Text("Privacy")
            Spacer()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                }
                .foregroundColor(.green)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

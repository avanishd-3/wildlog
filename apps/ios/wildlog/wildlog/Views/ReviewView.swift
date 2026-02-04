//
//  ReviewView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import SwiftUI

struct ReviewView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            // Tab Picker
            Picker("", selection: $selectedTab) {
                Text("Friends").tag(0)
                Text("You").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            Spacer()
            
            Text("Reviews")
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    ReviewView()
}

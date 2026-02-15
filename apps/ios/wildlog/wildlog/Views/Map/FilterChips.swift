//
//  FilterChips.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/14/26.
//

import SwiftUI

// FilterChips: horizontal row of selectable filter buttons
struct FilterChips: View {
    let title: String
    let options: [String]
    let selected: String?
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack {
                ForEach(options, id: \.self) { option in
                    Button(action: { onSelect(option) }) {
                        Text(option)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selected == option ? Color.accentColor.opacity(0.15) : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selected == option ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
                    )
                }
            }
        }
    }
}

//#Preview {
//    FilterChips(title: "Cost", options: ["Low", "Medium", "High"], selected: "Medium",)
//    })
//}

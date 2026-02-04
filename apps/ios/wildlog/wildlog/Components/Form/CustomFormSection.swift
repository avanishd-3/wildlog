//
//  CustomFormSection.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/3/26.
//

// Have form styling on lists of items w/ scrollability

import SwiftUI

struct CustomFormSection<Content: View>: View {
    let title: String?
    let content: Content
    
    init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
            
            self.title = title
            self.content = content()
    }
    
    var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                if let title {
                    Text(title)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                }

                VStack(spacing: 0) {
                    content
                }
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.horizontal)
        }
}

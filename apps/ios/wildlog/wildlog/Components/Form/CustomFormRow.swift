//
//  CustomFormRow.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/3/26.
//

import SwiftUI

struct CustomFormRow<Destination: View>: View {
    let title: String
    let destination: Destination
    
    // ViewBuilder so view is only built when navigating to it (not on form load)
    // The _ means you don't need to specify title when making a form row
    init(_ title: String, @ViewBuilder destination: @escaping () -> Destination) {
        self.title = title
        self.destination = destination()
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal)
            .frame(minHeight: 44)
            .contentShape(Rectangle()) // Makes rows easier to tap
        }
        .buttonStyle(.plain)
    }
}

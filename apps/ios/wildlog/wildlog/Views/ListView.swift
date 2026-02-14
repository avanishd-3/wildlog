//
//  ListView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import SwiftUI

// TODO: Replace with actual list view
struct ListView: View {
    var parkViewModel = ParkViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            Text("List View")
                .font(.largeTitle)
            Spacer()
            
            Button("Fetch park info") {
                parkViewModel.fetchPark()
            }
            
            Text(parkViewModel.name)
        }.frame(maxWidth: .infinity)
    }
}

#Preview {
    ListView()
}

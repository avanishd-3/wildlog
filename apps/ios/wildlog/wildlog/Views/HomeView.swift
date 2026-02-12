//
//  HomeView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Popular this week")
                CarouselView()
                Spacer()
                Text("Popular with friends")
                CarouselView()
            }.frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    HomeView()
}

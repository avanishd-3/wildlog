//
//  HomeView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Home View")
                .font(.largeTitle)
            Spacer()
        }.frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView()
}

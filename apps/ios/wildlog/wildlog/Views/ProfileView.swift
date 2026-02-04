//
//  ProfileView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Username")
                Circle()
                    .fill(Color(UIColor.tertiarySystemGroupedBackground))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                    )
                
                Text("Bio goes here")
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Favorite Parks")
                        .padding(.leading, 10)
                    CarouselView()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Recent Activity")
                        .padding(.leading, 10)
                    CarouselView()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}

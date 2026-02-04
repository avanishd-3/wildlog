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
            // Top row
            // Should not be scrollable
            HStack {
                NavigationLink {
                    SettingsPageView()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundStyle(.gray)
                }

                Spacer()

                Text("Username")
                    .font(.headline)

                Spacer()

                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .font(.title2)
            }
            .padding(.horizontal)
            .padding(.top)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Avatar section
                    HStack {
                        Spacer()
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(.gray)
                        Spacer()
                    }

                    // Favorite Parks
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Favorite Parks")
                            .font(.headline)

                        HStack {
                            ForEach(0..<4) { _ in
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray5))
                                    .frame(width: 80, height: 80)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Recent Activity
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Activity")
                            .font(.headline)

                        HStack {
                            ForEach(0..<4) { _ in
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray5))
                                    .frame(width: 80, height: 80)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Form-style sections
                    Form {
                        Section(header: Text("Your Outdoors")) {
                            Text("This is a sample form section.")
                        }
                    }
                    VStack(spacing: 24) {
                        CustomFormSection("Your Outdoors") {
                            CustomFormRow("Parks") {
                                Text("Parks")
                            }
                            CustomFormDivider()

                            CustomFormRow("Diary") {
                                Text("Diary")
                            }
                            CustomFormDivider()

                            CustomFormRow("Reviews") {
                                Text("Reviews")
                            }
                            CustomFormDivider()

                            CustomFormRow("Lists") {
                                ListView()
                            }
                            CustomFormDivider()

                            CustomFormRow("Bucket List") {
                                Text("Bucket List")
                            }
                            CustomFormDivider()

                            CustomFormRow("Likes") {
                                Text("Likes")
                            }
                        }

                        CustomFormSection("Social") {
                            CustomFormRow("Followers") {
                                Text("Followers")
                            }
                            CustomFormDivider()

                            CustomFormRow("Following") {
                                Text("Following")
                            }
                        }
                    }
                }
                .padding(8)
            }
        }
    }
}

#Preview {
    ProfileView()
}

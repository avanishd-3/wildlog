//
//  ProfileView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

import SwiftUI
import WildLogAPI

struct ProfileView: View {
    @Binding var selectedTab: Tabs

    @State private var userInfo: GetUserInfoQuery.Data.Me?

    @State private var name = ""
    @State private var userName = ""
    @State private var email = ""
    @State private var website = ""
    @State private var bio = ""

    private func getUserInfo() async throws {
        let response = try await apolloClient.fetch(query: GetUserInfoQuery())
        userInfo = response.data?.me
        name = userInfo?.name ?? ""
        userName = userInfo?.username ?? "Username"
        email = userInfo?.email ?? ""
        website = userInfo?.website ?? ""
        bio = userInfo?.bio ?? ""
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    // MARK: - Header Bar
                    HStack {
                        NavigationLink {
                            SettingsView(selectedTab: $selectedTab, name: $name, email: $email, userWebsite: $website, userBio: $bio)
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.title2)
                                .foregroundStyle(.primary)
                        }

                        Spacer()

                        Text(userName)
                            .font(.headline)

                        Spacer()

                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .font(.title2)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)

                    // MARK: - Avatar + Name
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 88, height: 88)
                            .foregroundStyle(Color(.systemGray3))

                        VStack(spacing: 4) {
                            if !name.isEmpty {
                                Text(name)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            if !bio.isEmpty {
                                Text(bio)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 28)

                    // MARK: - Favorite Parks
                    ProfileSection(title: "Favorite Parks") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<4) { _ in
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray5))
                                        .frame(width: 88, height: 88)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // MARK: - Recent Activity
                    ProfileSection(title: "Recent Activity") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<4) { _ in
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemGray5))
                                        .frame(width: 88, height: 88)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // MARK: - Your Outdoors
                    ProfileSection(title: "Your Outdoors") {
                        ProfileFormGroup {
                            ProfileFormRow(label: "Parks", icon: "tree") { Text("Parks") }
                            ProfileFormRow(label: "Diary", icon: "book") { Text("Diary") }
                            ProfileFormRow(label: "Reviews", icon: "star") { Text("Reviews") }
                            ProfileFormRow(label: "Lists", icon: "list.bullet") { ListView() }
                            ProfileFormRow(label: "Bucket List", icon: "clock.badge.checkmark") { BucketListView() }
                            ProfileFormRow(label: "Likes", icon: "heart", isLast: true) { LikedParksView() }
                        }
                    }

                    // MARK: - Social
                    ProfileSection(title: "Social") {
                        ProfileFormGroup {
                            ProfileFormRow(label: "Followers", icon: "person.2") { Text("Followers") }
                            ProfileFormRow(label: "Following", icon: "person.badge.plus", isLast: true) { Text("Following") }
                        }
                    }

                    Spacer(minLength: 32)
                }
            }
            .scrollIndicators(.hidden)
        }
        .task {
            do {
                try await getUserInfo()
            } catch {}
        }
    }
}

// MARK: - Profile Section

private struct ProfileSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)
            content()
        }
        .padding(.bottom, 28)
    }
}

// MARK: - Profile Form Group

private struct ProfileFormGroup<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// MARK: - Profile Form Row

private struct ProfileFormRow<Destination: View>: View {
    let label: String
    let icon: String
    var isLast: Bool = false
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: destination) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundStyle(.green)
                        .frame(width: 28)
                    Text(label)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(Color(.systemGray3))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            if !isLast {
                Divider()
                    .padding(.leading, 56)
            }
        }
    }
}

#Preview {
    ProfileView(selectedTab: .constant(.home))
}

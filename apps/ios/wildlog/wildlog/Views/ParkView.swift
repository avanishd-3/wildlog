//
//  ParkDetailView.swift
//  wildlog
//
//  Created by Derek Cao on 2/9/26.
//

import SwiftUI
import WildLogAPI

struct ParkDetailView: View {
    let park: Park
    @Environment(\.dismiss) private var dismiss

    @Environment(LikeManager.self) private var likeManager
    @Environment(BucketListManager.self) private var bucketListManager

    @State private var showWriteReview = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: - Hero Image
                // Using .background on a Color spacer is the reliable way to get
                // a full-bleed image in a ScrollView without ignoresSafeArea
                // pushing all child content out of bounds.
                Color.clear
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .background(
                        Group {
                            if let imageUrl = park.imageUrl, let url = URL(string: imageUrl) {
                                RemoteImage(url: url)
                                    .scaledToFill()
                            } else if let imageName = park.imageName {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Color(.systemGray5)
                            }
                        }
                        .clipped()
                    )
                    .clipped()

                // MARK: - Gradient + Park Name
                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [.clear, Color(.systemBackground)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 60)
                    .padding(.top, -60) // pull gradient up to overlap image

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(park.designation)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                            Text(park.name)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }

                // MARK: - Action Buttons
                HStack(spacing: 12) {
                    ActionButton(
                        icon: likeManager.isLiked(park.id.uuidString) ? "heart.fill" : "heart",
                        label: "Like",
                        isActive: likeManager.isLiked(park.id.uuidString),
                        activeColor: .green
                    ) {
                        likeManager.toggleLike(for: park.id.uuidString)
                    }

                    ActionButton(
                        icon: bucketListManager.isInBucketList(park.id.uuidString) ? "clock.badge.checkmark.fill" : "clock.badge.checkmark",
                        label: "Bucket List",
                        isActive: bucketListManager.isInBucketList(park.id.uuidString),
                        activeColor: .orange
                    ) {
                        bucketListManager.toggleBucketList(for: park.id.uuidString)
                    }

                    ActionButton(
                        icon: "square.and.pencil",
                        label: "Review",
                        isActive: false,
                        activeColor: .blue
                    ) {
                        showWriteReview = true
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 28)

                // MARK: - About
                DetailSection(title: "About") {
                    Text(park.description)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // MARK: - Details
                DetailSection(title: "Details") {
                    VStack(spacing: 0) {
                        DetailRow(label: "State", value: park.states)
                        Divider()
                        DetailRow(label: "Type", value: park.type)
                        Divider()
                        DetailRow(
                            label: "Entrance Fee",
                            value: park.free ? "Free" : "$\(park.cost)"
                        )
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // MARK: - Location
                DetailSection(title: "Location") {
                    VStack(spacing: 0) {
                        DetailRow(label: "Latitude", value: String(format: "%.4f", park.latitude))
                        Divider()
                        DetailRow(label: "Longitude", value: String(format: "%.4f", park.longitude))
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer(minLength: 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white, Color.black.opacity(0.3))
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showWriteReview) {
            WriteReviewSheet(park: park)
        }
        .onAppear {
            Task {
                do {
                    let parkIdString = park.id.uuidString
                    let result = try await apolloClient.fetch(query: LikeAndBucketListStatusQuery(parkPublicId: parkIdString))
                    if let isLiked = result.data?.isParkLiked, isLiked {
                        likeManager.likePark(for: parkIdString)
                    }
                    if let isInBucketList = result.data?.isParkBucketListed, isInBucketList {
                        bucketListManager.addtoBucketList(for: parkIdString)
                    }
                } catch {
                    // TODO: Handle error
                }
            }
        }
    }
}

// MARK: - Action Button

private struct ActionButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let activeColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(isActive ? activeColor : .secondary)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(isActive ? activeColor : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Detail Section

private struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal)
            content()
                .padding(.horizontal)
        }
        .padding(.bottom, 24)
    }
}

// MARK: - Detail Row

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    NavigationStack {
        ParkDetailView(park: ParkData.sampleParks[0])
            .environment(LikeManager())
            .environment(BucketListManager())
    }
}

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
        Form {
            // Park Image Section with Like and Bucket List Buttons
            Section {
                
                ZStack(alignment: .topTrailing) {
                    if let imageUrl = park.imageUrl, let url = URL(string: imageUrl) {
                        RemoteImage(url: url)
                    }
                
                    else if let imageName = park.imageName {
                      Image(imageName)
                          .resizable()
                          .scaledToFill()
                          .frame(maxWidth: .infinity)
                          .frame(height: 250)
                          .clipped()
                          .listRowInsets(EdgeInsets())
                    }
                    
                    // Action buttons in top-right
                    HStack(spacing: 20) {
                        // Bucket list button
                        Button {
                            bucketListManager.toggleBucketList(for: park.id.uuidString)
                        } label: {
                            Image(systemName: bucketListManager.isInBucketList(park.id.uuidString) ? "clock.badge.checkmark.fill" : "clock.badge.checkmark")
                                .font(.title)
                                .foregroundStyle(bucketListManager.isInBucketList(park.id.uuidString) ? Color(.systemOrange) : .white)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                )
                                .shadow(radius: 4)
                        }
                        .buttonStyle(.plain)
                        
                        // Like button
                        // Green like rest of app
                        Button {
                            likeManager.toggleLike(for: park.id.uuidString)
                        } label: {
                            Image(systemName: likeManager.isLiked(park.id.uuidString) ? "heart.fill" : "heart")
                                .font(.title)
                                .foregroundStyle(likeManager.isLiked(park.id.uuidString) ? Color(.systemGreen) : .white)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                )
                                .shadow(radius: 4)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                }
                .listRowInsets(EdgeInsets())
            }
            
            // Description Section
            Section(header: Text("About")) {
                Text(park.description)
            }
            
            // Details Section
            Section(header: Text("Details")) {
                HStack {
                    Text("Designation")
                    Spacer()
                    Text(park.designation)
                }
                
                HStack {
                    Text("State")
                    Spacer()
                    Text(park.states)
                }
                
                HStack {
                    Text("Type")
                    Spacer()
                    Text(park.type)
                }
                
                HStack {
                    Text("Entrance Fee")
                    Spacer()
                    if park.free {
                        Text("Free")
                    } else {
                        Text("$\(park.cost)")
                    }
                }
            }
            
            // Location Section
            Section(header: Text("Location")) {
                HStack {
                    Text("Latitude")
                    Spacer()
                    Text(String(park.latitude))
                }
                
                HStack {
                    Text("Longitude")
                    Spacer()
                    Text(String(park.longitude))
                }
            }
            
            // Quick Review Section
            Section {
                Button {
                    showWriteReview = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Write a Review")
                        Spacer()
                    }
                }
            }
        }
        .navigationBarTitle(park.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
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
                    if let isLiked = result.data?.isParkLiked {
                        debugPrint("Checking if park is liked...")
                        // Park is liked so toggle it
                        if isLiked {
                            debugPrint("Park is liked, so toggle it...")
                            likeManager.likePark(for: parkIdString)
                        }
                    }
                    
                    if let isInBucketList = result.data?.isParkBucketListed {
                        // Park in bucket list, so toggle it
                        if isInBucketList {
                            bucketListManager.addtoBucketList(for: parkIdString)
                        }
                    }
                } catch {
                    // TODO: Handle error
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ParkDetailView(park: ParkData.sampleParks[0])
            .environment(LikeManager())
            .environment(BucketListManager())
    }
}

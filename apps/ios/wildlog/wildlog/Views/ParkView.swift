//
//  ParkDetailView.swift
//  wildlog
//
//  Created by Derek Cao on 2/9/26.
//

import SwiftUI

// Basic apple settings-like design will probably change later to make it look more stylized
struct ParkDetailView: View {
    let park: Park
    @Environment(\.dismiss) private var dismiss
    
    // Like functionality
    @Environment(LikeManager.self) private var likeManager
    
    private var isLiked: Bool {
        likeManager.isLiked(park.id.uuidString)
    }

    var body: some View {
        Form {
            // Park Image Section
            Section {
                ZStack(alignment: .topTrailing) {
                    if let imageName = park.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .clipped()
                    }
                    
                    // Like button overlay on image
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            likeManager.toggleLike(for: park.id.uuidString)
                        }
                    } label: {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundStyle(isLiked ? .red : .white)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                            )
                            .shadow(radius: 4)
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
    }
}

#Preview {
    NavigationStack {
        ParkDetailView(park: ParkData.sampleParks[0])
            .environment(LikeManager())
    }
}

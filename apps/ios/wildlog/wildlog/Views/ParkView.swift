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

    var body: some View {
        Form {
            // Park Image Section
            Section {
                if let imageUrl = park.imageUrl {
                    AsyncImage(url: URL(string: imageUrl))
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        .clipped()
                        .listRowInsets(EdgeInsets())
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
    }
}

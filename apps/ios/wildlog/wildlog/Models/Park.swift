//
//  Park.swift
//  wildlog
//
//  Created by Derek Cao on 2/9/26.
//

import Foundation
import WildLogAPI

struct Park: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let designation: String
    let latitude: Double
    let longitude: Double
    let states: String
    let type: String
    let free: Bool
    let cost: Int
    let imageName: String?
    
    // Will be a URL, GraphQL just doesn't have a URL type
    // Optional so previews can use image name
    let imageUrl: String?
}

// Custom init for Park
// See: https://www.hackingwithswift.com/example-code/language/how-to-add-a-custom-initializer-to-a-struct-without-losing-its-memberwise-initializer
extension Park {
    // MARK: Create park based on result of graph ql query
    // Having 3 different ones is duplication, but we only get results from these places, so it's fine
    
    
    init?(from gql: GetParkMapRecommendationsQuery.Data.GetParkMapRecommendation) {
        guard let lat = gql.latitude, let lon = gql.longitude else { return nil }
        self.init(
            id: UUID(uuidString: gql.id) ?? UUID(),
            name: gql.name,
            description: gql.description,
            designation: removeUnderscoreAndAllCaps(for: gql.designation.rawValue),
            latitude: lat,
            longitude: lon,
            states: gql.states,
            type: removeUnderscoreAndAllCaps(for: gql.type.rawValue),
            free: gql.free,
            cost: gql.cost,
            imageName: nil,
            imageUrl: gql.imageUrl
        )
    }
    
    init?(from gql: GetHomePageRecommendationsQuery.Data.GetCommunityRecommendation) {
        guard let lat = gql.latitude, let lon = gql.longitude else { return nil }
        self.init(
            id: UUID(uuidString: gql.id) ?? UUID(),
            name: gql.name,
            description: gql.description,
            designation: removeUnderscoreAndAllCaps(for: gql.designation.rawValue),
            latitude: lat,
            longitude: lon,
            states: gql.states,
            type: removeUnderscoreAndAllCaps(for: gql.type.rawValue),
            free: gql.free,
            cost: gql.cost,
            imageName: nil,
            imageUrl: gql.imageUrl
        )
    }
    
    init?(from gql: GetHomePageRecommendationsQuery.Data.GetForYouRecommendation) {
        guard let lat = gql.latitude, let lon = gql.longitude else { return nil }
        self.init(
            id: UUID(uuidString: gql.id) ?? UUID(),
            name: gql.name,
            description: gql.description,
            designation: removeUnderscoreAndAllCaps(for: gql.designation.rawValue),
            latitude: lat,
            longitude: lon,
            states: gql.states,
            type: removeUnderscoreAndAllCaps(for: gql.type.rawValue),
            free: gql.free,
            cost: gql.cost,
            imageName: nil,
            imageUrl: gql.imageUrl
        )
    }
    
    init?(from gql: GetLikedParksQuery.Data.LikedPark) {
        guard let lat = gql.latitude, let lon = gql.longitude else { return nil }
        self.init(
            id: UUID(uuidString: gql.id) ?? UUID(),
            name: gql.name,
            description: gql.description,
            designation: removeUnderscoreAndAllCaps(for: gql.designation.rawValue),
            latitude: lat,
            longitude: lon,
            states: gql.states,
            type: removeUnderscoreAndAllCaps(for: gql.type.rawValue),
            free: gql.free,
            cost: gql.cost,
            imageName: nil,
            imageUrl: gql.imageUrl
        )
    }
    
    init?(from gql: GetBucketListedParksQuery.Data.BucketListedPark) {
        guard let lat = gql.latitude, let lon = gql.longitude else { return nil }
        self.init(
            id: UUID(uuidString: gql.id) ?? UUID(),
            name: gql.name,
            description: gql.description,
            designation: removeUnderscoreAndAllCaps(for: gql.designation.rawValue),
            latitude: lat,
            longitude: lon,
            states: gql.states,
            type: removeUnderscoreAndAllCaps(for: gql.type.rawValue),
            free: gql.free,
            cost: gql.cost,
            imageName: nil,
            imageUrl: gql.imageUrl
        )
    }
}

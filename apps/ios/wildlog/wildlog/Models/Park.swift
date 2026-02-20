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
    let cost: String?
    let imageName: String?
}

// Custom init for Park
// See: https://www.hackingwithswift.com/example-code/language/how-to-add-a-custom-initializer-to-a-struct-without-losing-its-memberwise-initializer
extension Park {
    // Create park based on result of graph ql query
    // TODO: Add free, cost, and imageName to GraphQL API
    init?(from gql: GetParkMapRecommendationsQuery.Data.GetParkMapRecommendation) {
        guard let lat = gql.latitude, let lon = gql.longitude else { return nil }
        self.init(
            id: UUID(uuidString: gql.id) ?? UUID(),
            name: gql.name,
            description: gql.description,
            designation: gql.designation.rawValue,
            latitude: lat,
            longitude: lon,
            states: gql.states,
            type: gql.type.rawValue,
            free: false,
            cost: nil,
            imageName: nil
        )
    }
}

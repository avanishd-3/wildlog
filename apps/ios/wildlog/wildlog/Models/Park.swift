//
//  Park.swift
//  wildlog
//
//  Created by Derek Cao on 2/9/26.
//

import Foundation

struct Park: Identifiable, Codable {
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

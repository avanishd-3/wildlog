//
//  ParkData.swift
//  wildlog
//
//  Created by Derek Cao on 2/9/26.
//

import Foundation

// This is just sample data for previews only.
// TODO: Replace with data from recommendation system API
class ParkData {
    static let sampleParks: [Park] = [
        Park(
            id: UUID(),
            name: "Acadia National Park",
            description: "This coastal park in Maine spans most of Mount Desert Island and nearby islands. It features Cadillac Mountain, the tallest peak on the Atlantic coast, rugged granite coastline, and extensive woodlands and lakes. A mosaic of habitats—freshwater ponds, estuaries, intertidal zones, and forest—supports peregrine falcons, harbor seals, white-tailed deer, and a rich array of seabirds.",
            designation: "National Park",
            latitude: 44.409286,
            longitude: -68.247501,
            states: "ME",
            type: "National",
            free: false,
            cost: "$6",
            imageName: "acadia"
        ),
        Park(
            id: UUID(),
            name: "Yosemite National Park",
            description: "This iconic park in California's Sierra Nevada features dramatic granite cliffs, glacially carved valleys, and ancient giant sequoias. Famed for Yosemite Valley, it is home to El Capitan, Half Dome, Yosemite Falls, and Bridalveil Fall, with sweeping meadows, alpine lakes, and backcountry trails. Wildlife includes black bears, mule deer, coyotes, bobcats, and mountain lions.",
            designation: "National Park",
            latitude: 37.8488329,
            longitude: -119.55719,
            states: "CA",
            type: "National",
            free: false,
            cost: "$35",
            imageName: "yosemite"
        ),
        Park(
            id: UUID(),
            name: "Zion National Park",
            description: "Zion National Park sits in southwestern Utah, where the Virgin River has carved dramatic canyons through towering Navajo sandstone. The park features iconic hikes like Angels Landing and The Narrows, scenic drives, and backcountry exploration amid red rock cliffs, with wildlife including mule deer, desert bighorn sheep, and a variety of birds.",
            designation: "National Park",
            latitude: 37.2983925,
            longitude: -113.02651,
            states: "UT",
            type: "National",
            free: false,
            cost: "$35",
            imageName: "zion"
        ),
        Park(
            id: UUID(),
            name: "Canyonlands National Park",
            description: "This vast desert region in southeastern Utah consists of three units—Island in the Sky, The Needles, and The Maze. Dramatic canyons carved by the Colorado and Green Rivers rise beside sweeping vistas from cliff-edge overlooks, offering scenic drives, backcountry hiking, and challenging canyoneering and 4x4 routes. Wildlife includes mule deer, desert bighorn sheep, coyotes, and rock squirrels, while ancient Puebloan rock art and ruins dot the canyon walls.",
            designation: "National Park",
            latitude: 38.2455578,
            longitude: -109.88016,
            states: "UT",
            type: "National",
            free: false,
            cost: "$30",
            imageName: "canyonlands"
        ),
        Park(
            id: UUID(),
            name: "Glacier National Park",
            description: "This region in the northern Rocky Mountains of Montana is a national park famed for its dramatic, glacier-carved peaks, sweeping valleys, and pristine alpine lakes. The Going-to-the-Sun Road is the centerpiece, threading through high passes and forested scenery, while numerous scenic drives and backcountry hiking opportunities reveal the park's wild beauty. Wildlife includes grizzly bears, black bears, moose, elk, mountain goats, and bighorn sheep.",
            designation: "National Park",
            latitude: 48.6841468,
            longitude: -113.80093,
            states: "MT",
            type: "National",
            free: false,
            cost: "$35",
            imageName: "glacier"
        ),
        Park(
            id: UUID(),
            name: "Bryce Canyon National Park",
            description: "Bryce Canyon National Park, in southern Utah, features a surreal landscape of multicolored hoodoo spires rising from red-rock amphitheaters. Scenic drives along the rim and backcountry hiking opportunities among the hoodoos reveal dramatic vistas and night-sky views. Wildlife includes mule deer, pronghorn, bighorn sheep, and peregrine falcons.",
            designation: "National Park",
            latitude: 37.5839914,
            longitude: -112.18267,
            states: "UT",
            type: "National",
            free: false,
            cost: "$35",
            imageName: "bryce"
        )
    ]
    
    static func getPark(byImageName imageName: String) -> Park? {
        return sampleParks.first { $0.imageName == imageName }
    }
}

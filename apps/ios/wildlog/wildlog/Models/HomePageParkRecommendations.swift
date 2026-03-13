//
//  HomePageParkRecommendations.swift
//  WildLog
//
//  Created by Avanish Davuluri on 3/13/26.
//

import Foundation

// Holder for home page recommendations to make modifying the home page in the future easier
struct HomePageParkRecommendations {
    // Need these to be var b/c they are edited by response from GraphQL API
    var communityParks: [Park]
    var forYouParks: [Park]
    
    // Fix compile errors from previews
    init(from: Any = ()) {
        communityParks = []
        forYouParks = []
    }
}

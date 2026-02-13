//
//  ApolloClient.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/13/26.
//

import Foundation
import Apollo

// MARK: Hard-coding server value since we're not deploying
let apolloClient = ApolloClient(url: URL(string: "https://localhost:3000/graphql")!)

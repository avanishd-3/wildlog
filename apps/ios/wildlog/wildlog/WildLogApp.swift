//
//  WildLogApp.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/1/26.
//

import SwiftUI
import SwiftData

@main
struct WildLogApp: App {
    @State var launchScreenState = LaunchScreenStateManager()
    @State var authManager = AuthenticationManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                
//                if launchScreenState.state != .finished {
//                    LaunchScreenView()
//                }
            }
        }
//        .environment(launchScreenState)
        .environment(authManager)
        .modelContainer(sharedModelContainer)
    }
}

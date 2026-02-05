//
//  ContentView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

// Landing page view for the app
// Just contains all the 

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tabs = .home
    
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    
    var body: some View {
            
        // **Important**: Do not set tint or accent color. It applies globally
        UIKitTabView(selectedTab: $selectedTab)
        .task {
            // TODO: Replace with actual API call
            // This is just a placeholder for now
            try? await Task.sleep(for: .seconds(3))
            self.launchScreenState.dismiss()
        }
    }
}

// We need to do this so the tabs are green only when selected
// Apple removed the ability to modify tab color with the new API
// so we need to dip into UIKit
struct UIKitTabView: UIViewControllerRepresentable {
    @Binding var selectedTab: Tabs
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIHostingController(rootView: SwiftUITabView(selectedTab: $selectedTab))
        
        // See: https://code-examples.net/en/q/4c170ed/mastering-uitabbarappearance-solving-icon-color-bugs-in-ios-26
        
        // TODO: The search one is still over-ridden. I don't know if this map taking over weirdly but I have no idea how to fix it
        
        let appearance = UITabBarAppearance()
        let itemAppearance = UITabBarItemAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Change selected tab color to green
        itemAppearance.selected.iconColor = .systemGreen
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemGreen]
        
        itemAppearance.normal.iconColor = .systemGray
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance // Make sure tab color doesn't change when scrolling
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            if let hostingController = uiViewController as? UIHostingController<SwiftUITabView> {
                hostingController.rootView = SwiftUITabView(selectedTab: $selectedTab)
            }
        }
}

struct SwiftUITabView: View {
    @Binding var selectedTab: Tabs

    var body: some View {
        if #available(iOS 18.0, *) {
            TabView(selection: $selectedTab) {
                Tab("Home", systemImage: "house", value: .home) {
                    HomeView()
                }
                Tab("Your Lists", systemImage: "list.bullet", value: .lists) {
                    ListView()
                }
                Tab("Search", systemImage: "magnifyingglass", value: .map) {
                    SearchView()
                }
                Tab("Reviews", systemImage: "sparkles", value: .reviews) {
                    ReviewView()
                }
                Tab("Profile", systemImage: "person.crop.circle", value: .profile) {
                    ProfileView()
                }
            }
        } else {
            // Fallback for iOS < 18
            TabView(selection: $selectedTab) {
                HomeView().tabItem {
                    Label("Home", systemImage: "house")
                        .tag(Tabs.home)
                }
                ListView()
                    .tabItem {
                        Label("Your Lists", systemImage: "list.bullet")
                    }
                    .tag(Tabs.lists)
                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(Tabs.map)
                    .tint(Color(.systemGreen))
                ReviewView()
                    .tabItem {
                        Label("Reviews", systemImage: "sparkles")
                    }
                    .tag(Tabs.reviews)
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                    .tag(Tabs.profile)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LaunchScreenStateManager())
    }
}

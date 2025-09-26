//
//  summaryApp.swift
//  summary
//
//

import SwiftUI
import SwiftData

@main
struct summaryApp: App {
    @State private var authManager = AuthenticationManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            VideoTranscription.self,
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
            Group {
                //if authManager.isAuthenticated {
                    MainTabView()
                //} else {
                //    HomeView()
                //}
            }
            .id(authManager.isAuthenticated)
            .environment(authManager)
        }
        .modelContainer(sharedModelContainer)
    }
}

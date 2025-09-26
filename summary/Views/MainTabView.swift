//
//  MainTabView.swift
//  summary
//
//  Created by Assistant on 23/09/2025.
//

import SwiftUI
import SwiftData

enum MainTabs {
    case home, history, search
}

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: MainTabs = .home
    @State private var youtubeProcessor: YouTubeProcessor?

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "play.rectangle.fill", value: .home) {
                NavigationStack {
                    if let processor = youtubeProcessor {
                        YouTubeHomeView()
                            .environmentObject(processor)
                    } else {
                        ProgressView("Initialisation...")
                    }
                }
            }

            Tab("History", systemImage: "clock.fill", value: .history) {
                NavigationStack {
                    TranscriptionHistoryView()
                }
            }

            Tab(value: .search, role: .search) {
                NavigationStack {
                    TranscriptionSearchView()
                }
            }
        }
        .onAppear {
            if youtubeProcessor == nil {
                youtubeProcessor = YouTubeProcessor(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    MainTabView()
}

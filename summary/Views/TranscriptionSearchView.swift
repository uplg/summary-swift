//
//  TranscriptionSearchView.swift
//  summary
//
//  Created by Assistant on 23/09/2025.
//

import SwiftUI
import SwiftData

struct TranscriptionSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTranscriptions: [VideoTranscription]
    
    @State private var searchText = ""
    @State private var selectedTranscription: VideoTranscription?
    @State private var searchResults: [SearchResult] = []
    
    var body: some View {
        ZStack {
            // Contenu principal
            if searchText.isEmpty {
                EmptySearchView()
            } else if searchResults.isEmpty && !searchText.isEmpty {
                NoResultsView(searchText: searchText)
            } else {
                SearchResultsList(
                    results: searchResults,
                    searchText: searchText,
                    onTranscriptionTapped: { transcription in
                        selectedTranscription = transcription
                    }
                )
            }
        }
        .navigationTitle("Recherche")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Rechercher dans les transcriptions...")
        .sheet(item: $selectedTranscription) { transcription in
            TranscriptionDetailView(transcription: transcription)
        }
        .onChange(of: searchText) { _, newValue in
            if newValue.isEmpty {
                searchResults = []
            } else {
                performSearch()
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        let query = searchText.lowercased()
        var results: [SearchResult] = []
        
        for transcription in allTranscriptions {
            // Recherche dans le titre
            if transcription.videoTitle.lowercased().contains(query) {
                results.append(SearchResult(
                    transcription: transcription,
                    matchType: .title,
                    matchedText: transcription.videoTitle,
                    context: ""
                ))
            }
            
            // Recherche dans le résumé
            if transcription.summary.lowercased().contains(query) {
                let context = extractContext(from: transcription.summary, query: query)
                results.append(SearchResult(
                    transcription: transcription,
                    matchType: .summary,
                    matchedText: context,
                    context: context
                ))
            }
            
            // Recherche dans la transcription
            if transcription.transcriptionText.lowercased().contains(query) {
                let context = extractContext(from: transcription.transcriptionText, query: query)
                results.append(SearchResult(
                    transcription: transcription,
                    matchType: .transcription,
                    matchedText: context,
                    context: context
                ))
            }
        }
        
        // Supprimer les doublons et trier par pertinence
        searchResults = Array(Set(results)).sorted { $0.matchType.priority < $1.matchType.priority }
    }
    
    private func extractContext(from text: String, query: String) -> String {
        let lowercaseText = text.lowercased()
        let lowercaseQuery = query.lowercased()
        
        guard let range = lowercaseText.range(of: lowercaseQuery) else {
            return String(text.prefix(100))
        }
        
        let startIndex = max(text.startIndex, text.index(range.lowerBound, offsetBy: -50, limitedBy: text.startIndex) ?? text.startIndex)
        let endIndex = min(text.endIndex, text.index(range.upperBound, offsetBy: 50, limitedBy: text.endIndex) ?? text.endIndex)
        
        return String(text[startIndex..<endIndex])
    }
}

struct SearchResult: Hashable, Identifiable {
    let id = UUID()
    let transcription: VideoTranscription
    let matchType: MatchType
    let matchedText: String
    let context: String
    
    enum MatchType: CaseIterable {
        case title
        case summary
        case transcription
        
        var priority: Int {
            switch self {
            case .title: return 0
            case .summary: return 1
            case .transcription: return 2
            }
        }
        
        var displayName: String {
            switch self {
            case .title: return "Titre"
            case .summary: return "Résumé"
            case .transcription: return "Transcription"
            }
        }
        
        var icon: String {
            switch self {
            case .title: return "textformat.size"
            case .summary: return "doc.text"
            case .transcription: return "waveform"
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(transcription.id)
        hasher.combine(matchType)
    }
    
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.transcription.id == rhs.transcription.id && lhs.matchType == rhs.matchType
    }
}



struct EmptySearchView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Rechercher dans vos transcriptions")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Tapez un mot-clé pour rechercher dans les titres, résumés et transcriptions")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NoResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Aucun résultat")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Aucune transcription ne contient \"\(searchText)\"")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SearchResultsList: View {
    let results: [SearchResult]
    let searchText: String
    let onTranscriptionTapped: (VideoTranscription) -> Void
    
    var body: some View {
        List(results) { result in
            SearchResultRow(result: result, searchText: searchText)
                .onTapGesture {
                    onTranscriptionTapped(result.transcription)
                }
        }
        .listStyle(PlainListStyle())
    }
}

struct SearchResultRow: View {
    let result: SearchResult
    let searchText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.transcription.videoTitle.isEmpty ? "Vidéo YouTube" : result.transcription.videoTitle)
                        .font(.headline)
                        .lineLimit(2)
                    
                    HStack {
                        Image(systemName: result.matchType.icon)
                            .foregroundColor(.blue)
                            .font(.caption)
                        
                        Text("Trouvé dans: \(result.matchType.displayName)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                Text(result.transcription.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !result.context.isEmpty {
                Text(highlightedText(result.context, query: searchText))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func highlightedText(_ text: String, query: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        if let range = attributedString.range(of: query, options: .caseInsensitive) {
            attributedString[range].backgroundColor = .yellow
            attributedString[range].foregroundColor = .black
        }
        
        return attributedString
    }
}

#Preview {
    TranscriptionSearchView()
        .modelContainer(for: VideoTranscription.self, inMemory: true)
}

//
//  SearchResultsView.swift
//  summary
//
//  Created by Assistant on 23/09/2025.
//

import SwiftUI

struct SearchResultsView: View {
    @Binding var searchText: String
    
    init(searchText: Binding<String> = .constant("")) {
        self._searchText = searchText
    }
    
    private let allMangas = [
        "Naruto", "One Piece", "Attack on Titan", "Dragon Ball",
        "Death Note", "My Hero Academia", "Demon Slayer",
        "Tokyo Ghoul", "Fullmetal Alchemist", "Hunter x Hunter"
    ]
    
    private var filteredResults: [String] {
        if searchText.isEmpty {
            return allMangas // Montrer tous les mangas quand il n'y a pas de recherche
        }
        return allMangas.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        
        ZStack {
            AppBackground()
            
            if searchText.isEmpty {
                // Vue par défaut - suggestions ou contenu populaire
                VStack(spacing: 30) {
                    LiquidGlassCard(blur: 15, opacity: 0.08, cornerRadius: 20, shadowRadius: 10) {
                        VStack(spacing: 20) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color("JapanRed"), Color("JapanRed").opacity(0.7)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            
                            VStack(spacing: 10) {
                                Text("Découvrez des mangas")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("Tapez pour rechercher vos mangas préférés")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 40)
                    }
                    .padding(.horizontal, 30)
                    
                    // Suggestions populaires
                    VStack(alignment: .leading, spacing: 15) {
                        SectionHeader(title: "Populaires")
                            .padding(.horizontal, 10)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(Array(allMangas.prefix(5).enumerated()), id: \.offset) { index, manga in
                                    LiquidGlassCard(blur: 8, opacity: 0.06, cornerRadius: 12, shadowRadius: 6) {
                                        VStack(spacing: 8) {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 100, height: 140)
                                                .cornerRadius(8)
                                            
                                            Text(manga)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.center)
                                                .frame(width: 100)
                                        }
                                        .padding(10)
                                    }
                                }
                            }
                            .padding(.horizontal, 30)
                        }
                    }
                }
            } else {
                // Résultats de recherche
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(0..<filteredResults.count, id: \.self) { index in
                            LiquidGlassCard(blur: 8, opacity: 0.06, cornerRadius: 12, shadowRadius: 6) {
                                HStack(spacing: 15) {
                                    // Image du manga
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 80)
                                        .cornerRadius(8)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(filteredResults[index])
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text("Description du manga...")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationTitle("Recherche")
        .navigationBarTitleDisplayMode(.large)
    }
}


#Preview {
    SearchResultsView()
}

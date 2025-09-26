//
//  SearchView.swift
//  summary
//

import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    @Environment(\.isSearching) private var isSearching
    
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
            return []
        }
        return allMangas.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        
        ZStack {
            // Dynamic background with depth
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if !searchText.isEmpty {
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
            } else {
                // Vue par défaut
                LiquidGlassCard(blur: 15, opacity: 0.08, cornerRadius: 20, shadowRadius: 10) {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color("JapanRed"), Color("JapanRed").opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        VStack(spacing: 10) {
                            Text("Recherche")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Trouvez vos mangas préférés")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 60)
                }
                .padding(.horizontal, 30)
            }
        }
        .navigationTitle("Recherche")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, placement: .automatic, prompt: "Rechercher un manga...")
    }
}


#Preview {
    SearchView()
}

//
//  BookmarkView.swift
//  summary
//
import SwiftUI

struct BookmarkView: View {
    @State private var searchText = ""
    @State private var selectedFilter = 0
    let filterOptions = ["Tous", "En cours", "Terminés", "En attente"]

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 20) {
                HeaderView(
                    profileAction: {
                        // Profile action
                    }
                )

                // Search and filters section
                VStack(spacing: 15) {
                    // Search bar with liquid glass
                    LiquidGlassCard(blur: 8, opacity: 0.06, cornerRadius: 12, shadowRadius: 4) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)

                            TextField("Rechercher dans vos favoris...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding()
                    }
                    .padding(.horizontal, 20)

                    // Filter tabs with liquid glass
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Array(filterOptions.enumerated()), id: \.offset) { index, option in
                                LiquidGlassButton(action: {
                                    selectedFilter = index
                                }) {
                                    Text(option)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedFilter == index ? .white : Color("JapanRed"))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedFilter == index ? Color("JapanRed") : Color.clear
                                        )
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

                // Content
                ScrollView {
                    if searchText.isEmpty && selectedFilter == 0 {
                        // Empty state
                        VStack(spacing: 20) {
                            Spacer()

                            Image(systemName: "bookmark.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))

                            VStack(spacing: 8) {
                                Text("Aucun favori pour le moment")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)

                                Text("Explorez nos mangas et ajoutez-les à vos favoris pour les retrouver ici")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }

                            LiquidGlassButton(action: {
                                // Navigate to explore
                            }) {
                                Text("Explorer les mangas")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(Color("JapanRed"))
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .padding(.top, 10)

                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 400)
                    } else {
                        // Grid with manga cards
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 20) {
                            ForEach(0..<6) { index in
                                VStack(alignment: .leading, spacing: 10) {
                                    // Manga cover with liquid glass
                                    LiquidGlassCard(blur: 8, opacity: 0.06, cornerRadius: 12, shadowRadius: 6) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 200)
                                            .overlay(
                                                VStack {
                                                    Spacer()
                                                    HStack {
                                                        Spacer()
                                                        LiquidGlassButton(action: {
                                                            // Remove from favorites
                                                        }) {
                                                            Image(systemName: "bookmark.fill")
                                                                .font(.title3)
                                                                .foregroundColor(Color("JapanRed"))
                                                                .frame(width: 32, height: 32)
                                                        }
                                                        .padding(10)
                                                    }
                                                }
                                            )
                                    }

                                    // Manga info
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Manga Favori \(index + 1)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .lineLimit(1)

                                        Text("Chapitre 125")
                                            .font(.caption)
                                            .foregroundColor(.secondary)

                                        // Progress bar
                                        GeometryReader { geometry in
                                            ZStack(alignment: .leading) {
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(height: 4)

                                                Rectangle()
                                                    .fill(Color("JapanRed"))
                                                    .frame(width: geometry.size.width * 0.7, height: 4)
                                            }
                                            .cornerRadius(2)
                                        }
                                        .frame(height: 4)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

#Preview {
    BookmarkView()
}

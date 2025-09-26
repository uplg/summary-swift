//
//  DashboardView.swift
//  summary
//

import SwiftUI

struct DashboardView: View {

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(spacing: 30) {
                    HeaderView(
                        profileAction: {
                            // Profile action
                        }
                    )

                    // Main content section
                    VStack(alignment: .leading, spacing: 15) {
                        SectionHeader(
                            title: "Explorer",
                            actionTitle: "Voir tout"
                        ) {
                            // See all action
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(0..<3) { index in
                                    VStack(spacing: 8) {
                                        LiquidGlassCard(blur: 8, opacity: 0.06, cornerRadius: 12, shadowRadius: 4) {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(width: 120, height: 160)
                                                .overlay(
                                                    Image(systemName: "book.fill")
                                                        .font(.title)
                                                        .foregroundColor(Color("JapanRed").opacity(0.6))
                                                )
                                        }

                                        Text("Manga")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .multilineTextAlignment(.center)
                                            .frame(width: 120)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }

                    // Categories section
                    VStack(alignment: .leading, spacing: 15) {
                        SectionHeader(title: "Catégories")

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                            ForEach(["Action", "Romance", "Aventure", "Comédie"], id: \.self) { category in
                                LiquidGlassButton(action: {
                                    // Category action
                                }) {
                                    HStack {
                                        Text(category)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 30)
                }
            }
        }
    }
}

#Preview {
    DashboardView()
}

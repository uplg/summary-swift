//
//  AppBackground.swift
//  summary
//
//  Created by Assistant on 23/09/2025.
//

import SwiftUI

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemBackground),
                Color(.systemGray6).opacity(0.3)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    AppBackground()
}
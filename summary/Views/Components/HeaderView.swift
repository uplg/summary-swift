//
//  HeaderView.swift
//  summary
//
//  Created by Assistant on 23/09/2025.
//

import SwiftUI

struct HeaderView: View {
    let profileAction: (() -> Void)?

    init(profileAction: (() -> Void)? = nil) {
        self.profileAction = profileAction
    }

    var body: some View {
        LiquidGlassCard(blur: 12, opacity: 0.1, cornerRadius: 16, shadowRadius: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("漫画")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("JapanRed"), Color("JapanRed").opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    Text("SUMMARY")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(.primary)
                        .tracking(2)
                }

                Spacer()

                // Profile button with glass effect
                if let profileAction = profileAction {
                    LiquidGlassButton(action: profileAction) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(Color("JapanRed"))
                            .frame(width: 40, height: 40)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

#Preview {
    VStack {
        HeaderView(profileAction: {})
    }
    .padding()
    .background(
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemBackground),
                Color(.systemGray6).opacity(0.3)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    )
}
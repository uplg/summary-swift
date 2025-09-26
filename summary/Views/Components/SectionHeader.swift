//
//  SectionHeader.swift
//  summary
//
//  Created by Assistant on 23/09/2025.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(title: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        HStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Spacer()

            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle) {
                    action()
                }
                .foregroundColor(Color("JapanRed"))
                .font(.subheadline)
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    VStack(spacing: 20) {
        SectionHeader(title: "Populaires", actionTitle: "Voir tout") {
            print("Action")
        }

        SectionHeader(title: "Récemment ajoutés")
    }
    .padding()
}
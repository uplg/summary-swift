//
//  SettingsView.swift
//  summary
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var downloadQuality = 1
    @State private var autoDownload = false
    @Environment(AuthenticationManager.self) private var authManager

    let downloadQualityOptions = ["Faible", "Moyenne", "Haute"]

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(spacing: 20) {
                    HeaderView(
                        profileAction: {
                            // Profile action
                        }
                    )

                    // Settings sections
                    VStack(spacing: 25) {
                        // Account section
                        SettingsSection(title: "Compte") {
                            SettingsRow(
                                icon: "person.circle",
                                title: "Profil",
                                subtitle: "Modifier vos informations",
                                action: {
                                    // Profile action
                                }
                            )

                            SettingsRow(
                                icon: "envelope",
                                title: "Email",
                                subtitle: "user@example.com",
                                action: {
                                    // Email action
                                }
                            )

                            SettingsRow(
                                icon: "lock",
                                title: "Mot de passe",
                                subtitle: "Changer votre mot de passe",
                                action: {
                                    // Password action
                                }
                            )
                        }

                        // Reading preferences
                        SettingsSection(title: "Préférences de lecture") {
                            SettingsToggleRow(
                                icon: "moon.fill",
                                title: "Mode sombre",
                                subtitle: "Interface sombre pour la lecture",
                                isOn: $darkModeEnabled
                            )

                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "arrow.down.circle")
                                        .font(.title2)
                                        .foregroundColor(Color("JapanRed"))
                                        .frame(width: 30)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Qualité de téléchargement")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)

                                        Text("Choisir la qualité des images")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()
                                }

                                Picker("Qualité", selection: $downloadQuality) {
                                    ForEach(Array(downloadQualityOptions.enumerated()), id: \.offset) { index, option in
                                        Text(option).tag(index)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                            SettingsToggleRow(
                                icon: "icloud.and.arrow.down",
                                title: "Téléchargement automatique",
                                subtitle: "Télécharger les nouveaux chapitres",
                                isOn: $autoDownload
                            )
                        }

                        // Notifications
                        SettingsSection(title: "Notifications") {
                            SettingsToggleRow(
                                icon: "bell.fill",
                                title: "Notifications push",
                                subtitle: "Recevoir les notifications",
                                isOn: $notificationsEnabled
                            )

                            SettingsRow(
                                icon: "gear",
                                title: "Paramètres de notification",
                                subtitle: "Personnaliser les notifications",
                                action: {
                                    // Notification settings action
                                }
                            )
                        }

                        // Support section
                        SettingsSection(title: "Support") {
                            SettingsRow(
                                icon: "questionmark.circle",
                                title: "Aide & Support",
                                subtitle: "Centre d'aide et FAQ",
                                action: {
                                    // Help action
                                }
                            )

                            SettingsRow(
                                icon: "envelope.badge",
                                title: "Nous contacter",
                                subtitle: "Signaler un problème",
                                action: {
                                    // Contact action
                                }
                            )

                            SettingsRow(
                                icon: "doc.text",
                                title: "Conditions d'utilisation",
                                subtitle: "Lire les conditions",
                                action: {
                                    // Terms action
                                }
                            )

                            SettingsRow(
                                icon: "hand.raised",
                                title: "Politique de confidentialité",
                                subtitle: "Protection des données",
                                action: {
                                    // Privacy action
                                }
                            )
                        }

                        // App info
                        SettingsSection(title: "À propos") {
                            SettingsRow(
                                icon: "info.circle",
                                title: "Version de l'app",
                                subtitle: "1.0.0 (Build 1)",
                                action: nil
                            )
                        }

                        // Logout button with liquid glass
                        LiquidGlassButton(action: {
                            authManager.logout()
                        }) {
                            Text("Se déconnecter")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)

            VStack(spacing: 0) {
                content
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: (() -> Void)?

    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Color("JapanRed"))
                    .frame(width: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .liquidGlassStyle(cornerRadius: 12, shadowRadius: 6)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("JapanRed"))
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(Color("JapanRed"))
        }
        .padding()
        .liquidGlassStyle(cornerRadius: 12, shadowRadius: 6)
        .padding(.horizontal, 20)
    }
}

#Preview {
    SettingsView()
}

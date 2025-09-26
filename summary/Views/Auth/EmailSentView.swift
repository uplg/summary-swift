//
//  EmailSentView.swift
//  summary
//

import SwiftUI

struct EmailSentView: View {
    let email: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Dynamic background with depth
            GeometryReader { geometry in
                ZStack {
                    // Base gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.749, green: 0.188, blue: 0.188),
                            Color(red: 0.549, green: 0.088, blue: 0.088),
                            Color(red: 0.349, green: 0.058, blue: 0.058)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    // Floating blur elements for depth
                    Circle()
                        .fill(.white.opacity(0.07))
                        .blur(radius: 50)
                        .frame(width: 160, height: 160)
                        .offset(x: -80, y: -180)

                    Circle()
                        .fill(.white.opacity(0.04))
                        .blur(radius: 70)
                        .frame(width: 220, height: 220)
                        .offset(x: 100, y: 150)
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Logo section with liquid glass
                LiquidGlassCard(blur: 12, opacity: 0.06, cornerRadius: 18, shadowRadius: 8) {
                    VStack(spacing: 15) {
                        Text("漫画")
                            .font(.system(size: 45, weight: .bold, design: .serif))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)

                        Text("SUMMARY")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(4)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                }

                // Success content with liquid glass
                LiquidGlassCard(blur: 15, opacity: 0.08, cornerRadius: 20, shadowRadius: 10) {
                    VStack(spacing: 25) {
                        // Email icon with animation
                        Image(systemName: "envelope.badge.checkmark.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: true)

                        // Title
                        Text("Email envoyé !")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        // Description
                        VStack(spacing: 15) {
                            Text("Nous avons envoyé un lien de réinitialisation à :")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)

                            Text(email)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Text("Vérifiez votre boîte email (et vos spams) puis suivez les instructions pour créer un nouveau mot de passe.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 30)
                }

                Spacer()

                // Action buttons
                VStack(spacing: 15) {
                    // Back to login button with liquid glass
                    LiquidGlassButton(action: {
                        // Navigate back to login (dismiss twice)
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            dismiss()
                        }
                    }) {
                        Text("Retour à la connexion")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                    }
                    .padding(.horizontal, 30)

                    // Resend email button
                    Button(action: {
                        // Implement resend functionality
                    }) {
                        Text("Renvoyer l'email")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .underline()
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    EmailSentView(email: "user@example.com")
}

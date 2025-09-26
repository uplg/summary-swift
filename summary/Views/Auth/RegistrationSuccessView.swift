//
//  RegistrationSuccessView.swift
//  summary
//

import SwiftUI

struct RegistrationSuccessView: View {
    let email: String
    @Environment(\.dismiss) private var dismiss
    @State private var animationFinished = false
    @Environment(AuthenticationManager.self) private var authManager

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.749, green: 0.188, blue: 0.188),
                    Color(red: 0.549, green: 0.088, blue: 0.088)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Logo section
                VStack(spacing: 15) {
                    Text("漫画")
                        .font(.system(size: 50, weight: .bold, design: .serif))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                    Text("SUMMARY")
                        .font(.system(size: 24, weight: .light, design: .default))
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(3)
                }

                // Success content
                VStack(spacing: 30) {
                    // SwiftUI checkmark animation
                    CheckmarkAnimationView {
                        animationFinished = true
                    }
                    .frame(width: 80, height: 80)

                    // Title
                    Text("Inscription réussie !")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(animationFinished ? 1 : 0)
                        .animation(.easeIn(duration: 0.5).delay(0.5), value: animationFinished)

                    // Description
                    VStack(spacing: 15) {
                        Text("Bienvenue dans la communauté Summary !")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .opacity(animationFinished ? 1 : 0)
                            .animation(.easeIn(duration: 0.5).delay(0.7), value: animationFinished)

                        VStack(spacing: 8) {
                            Text("Un email de vérification a été envoyé à :")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)

                            Text(email)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .opacity(animationFinished ? 1 : 0)
                        .animation(.easeIn(duration: 0.5).delay(0.9), value: animationFinished)

                        Text("Vérifiez votre boîte email et cliquez sur le lien pour activer votre compte.")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .opacity(animationFinished ? 1 : 0)
                            .animation(.easeIn(duration: 0.5).delay(1.1), value: animationFinished)
                    }
                }

                Spacer()

                // Action buttons
                VStack(spacing: 15) {
                    // Continue to app button
                    Button(action: {
                        // Navigate to dashboard
                        authManager.setAuthenticated(true)
                    }) {
                        Text("Continuer vers l'app")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color("JapanRed"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.white)
                            .cornerRadius(27.5)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 30)
                    .opacity(animationFinished ? 1 : 0)
                    .animation(.easeIn(duration: 0.5).delay(1.3), value: animationFinished)

                    // Resend verification email
                    Button(action: {
                        // Implement resend verification email
                    }) {
                        Text("Renvoyer l'email de vérification")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .underline()
                    }
                    .opacity(animationFinished ? 1 : 0)
                    .animation(.easeIn(duration: 0.5).delay(1.5), value: animationFinished)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// Fallback SwiftUI checkmark animation
struct CheckmarkAnimationView: View {
    @State private var checkmarkScale: CGFloat = 0
    @State private var circleScale: CGFloat = 0
    @State private var showCheckmark = false
    @State private var checkmarkOffset: CGFloat = 0

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            // Circle background with subtle shadow
            Circle()
                .fill(Color(red: 0.749, green: 0.188, blue: 0.188))
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                .scaleEffect(circleScale)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: circleScale)

            // Checkmark with proper sizing
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(.white)
                .scaleEffect(checkmarkScale)
                .offset(y: checkmarkOffset)
                .opacity(showCheckmark ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.3), value: checkmarkScale)
        }
        .frame(width: 80, height: 80)
        .onAppear {
            withAnimation {
                circleScale = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    showCheckmark = true
                    checkmarkScale = 1.0
                    checkmarkOffset = 0
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                onComplete()
            }
        }
    }
}


#Preview {
    RegistrationSuccessView(email: "user@example.com")
}

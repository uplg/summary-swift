//
//  ForgotPasswordView.swift
//  summary
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Information"
    @Environment(\.dismiss) private var dismiss

    let onEmailSent: (String) -> Void

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
                        .fill(.white.opacity(0.05))
                        .blur(radius: 60)
                        .frame(width: 180, height: 180)
                        .offset(x: -90, y: -150)

                    Circle()
                        .fill(.white.opacity(0.03))
                        .blur(radius: 80)
                        .frame(width: 250, height: 250)
                        .offset(x: 100, y: 180)
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // Back button
                HStack {
                    LiquidGlassButton(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

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

                // Title and description
                VStack(spacing: 10) {
                    Text("Mot de passe oublié")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Entrez votre adresse email pour recevoir un lien de réinitialisation")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)

                // Email input section
                VStack(spacing: 20) {
                    AppTextField(
                        placeholder: "Votre adresse email",
                        text: $email,
                        icon: "envelope.fill",
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )
                    .padding(.horizontal, 30)

                    // Send reset button with liquid glass
                    LiquidGlassButton(action: {
                        sendResetEmail()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Envoyer le lien")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                    }
                    .disabled(isLoading || email.isEmpty || !isValidEmail)
                    .opacity(email.isEmpty || !isValidEmail ? 0.7 : 1.0)
                    .padding(.horizontal, 30)
                }

                Spacer()
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private var isValidEmail: Bool {
        email.contains("@") && email.contains(".")
    }

    private func sendResetEmail() {
        guard isValidEmail else {
            alertTitle = "Erreur"
            alertMessage = "Veuillez entrer une adresse email valide"
            showingAlert = true
            return
        }

        isLoading = true

        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isLoading = false
            onEmailSent(email)
        }
    }
}

#Preview {
    ForgotPasswordView(onEmailSent: { _ in })
}

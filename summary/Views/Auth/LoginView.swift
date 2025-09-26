//
//  LoginView.swift
//  summary
//
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var navigateToRegister = false
    @State private var navigateToForgotPassword = false
    @State private var navigateToEmailSent = false
    @State private var resetEmail = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthenticationManager.self) private var authManager

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
                        .fill(.white.opacity(0.08))
                        .blur(radius: 50)
                        .frame(width: 180, height: 180)
                        .offset(x: -120, y: -150)

                    Circle()
                        .fill(.white.opacity(0.04))
                        .blur(radius: 70)
                        .frame(width: 250, height: 250)
                        .offset(x: 100, y: 200)
                }
            }
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    // Logo section with liquid glass
                    LiquidGlassCard(blur: 15, opacity: 0.08, cornerRadius: 20, shadowRadius: 10) {
                        VStack(spacing: 10) {
                            Text("Uplg")
                                .font(.system(size: 50, weight: .bold, design: .serif))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .white.opacity(0.8)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)

                            Text("SUMMARY")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(.white.opacity(0.9))
                                .tracking(3)
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 25)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 20)

                    // Form section
                    VStack(spacing: 15) {
                        // Email field
                        AppTextField(
                            placeholder: "Email",
                            text: $email,
                            icon: "envelope.fill",
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )

                        // Password field
                        AppTextField(
                            placeholder: "Password",
                            text: $password,
                            icon: "lock.fill",
                            isSecure: true,
                            showToggle: true,
                            isSecureVisible: $isPasswordVisible
                        )
                    }
                    .padding(.horizontal, 30)

                    // Forgot password
                    HStack {
                        Spacer()
                        Button("Forgot password?") {
                            navigateToForgotPassword = true
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.trailing, 30)
                    }
                    .padding(.top, -10)

                    // Login button
                    Button(action: {
                        loginUser()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Login")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                        }
                        .foregroundColor(Color("JapanRed"))
                        .frame(width: 250, height: 55)
                        .background(Color.white)
                        .cornerRadius(27.5)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    .opacity(email.isEmpty || password.isEmpty ? 0.7 : 1.0)
                    .padding(.top, 20)

                    // Divider with OR
                    HStack {
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 1)

                        Text("OR")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 10)

                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)

                    // Social login buttons
                    VStack(spacing: 12) {
                        // Apple Sign In
                        Button(action: {
                            signInWithApple()
                        }) {
                            HStack(spacing: 10) {
                                Image("apple-black-logo-svgrepo-com")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text("Continue with Apple")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.black)
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 30)

                        // Google Sign In
                        Button(action: {
                            signInWithGoogle()
                        }) {
                            HStack(spacing: 10) {
                                Image("google")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text("Continue with Google")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.top, 10)

                    // Register link
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 14))

                        Button("Sign up") {
                            navigateToRegister = true
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    }
                    .padding(.top, 20)

                    Spacer()
                }
                .padding(.top, 80)
            }
        }
        .navigationDestination(isPresented: $navigateToRegister) {
            RegisterView()
                .navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $navigateToForgotPassword) {
            ForgotPasswordView(onEmailSent: { email in
                resetEmail = email
                navigateToEmailSent = true
            })
                .navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $navigateToEmailSent) {
            EmailSentView(email: resetEmail)
                .navigationBarBackButtonHidden(true)
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func loginUser() {
        isLoading = true
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false

            // Basic validation
            if email.contains("@") && !password.isEmpty {
                authManager.setAuthenticated(true)
            } else {
                alertMessage = "Invalid email or password"
                showingAlert = true
            }
        }
    }

    private func signInWithApple() {
        // Implement Apple Sign In
        // For now, simulate success
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            authManager.setAuthenticated(true)
        }
    }

    private func signInWithGoogle() {
        // Implement Google Sign In
        // For now, simulate success
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            authManager.setAuthenticated(true)
        }
    }
}

#Preview {
    LoginView()
}

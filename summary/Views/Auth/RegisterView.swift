//
//  RegisterView.swift
//  summary
//

import SwiftUI

struct RegisterView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var acceptTerms = false
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = "Error"
    @State private var navigateToRegistrationSuccess = false
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
                        .fill(.white.opacity(0.06))
                        .blur(radius: 50)
                        .frame(width: 200, height: 200)
                        .offset(x: -100, y: -180)

                    Circle()
                        .fill(.white.opacity(0.03))
                        .blur(radius: 70)
                        .frame(width: 280, height: 280)
                        .offset(x: 120, y: 220)
                }
            }
            .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Logo section with liquid glass
                        LiquidGlassCard(blur: 15, opacity: 0.08, cornerRadius: 20, shadowRadius: 10) {
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

                                Text("Create an account")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.top, 5)
                            }
                            .padding(.horizontal, 25)
                            .padding(.vertical, 20)
                        }
                        .padding(.bottom, 30)

                        // Form section
                        VStack(spacing: 15) {
                            // First name and Last name fields on same line
                            HStack(spacing: 10) {
                                AppTextField(
                                    placeholder: "First name",
                                    text: $firstName,
                                    icon: "person.fill"
                                )

                                AppTextField(
                                    placeholder: "Last name",
                                    text: $lastName
                                )
                            }

                            // Username field
                            AppTextField(
                                placeholder: "Username",
                                text: $username,
                                icon: "at",
                                autocapitalization: .never
                            )

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

                            // Confirm Password field
                            AppTextField(
                                placeholder: "Confirm password",
                                text: $confirmPassword,
                                icon: "lock.fill",
                                isSecure: true,
                                hasError: !passwordsMatch() && !confirmPassword.isEmpty,
                                showToggle: true,
                                isSecureVisible: $isConfirmPasswordVisible
                            )
                        }
                        .padding(.horizontal, 30)

                        // Terms and conditions checkbox
                        HStack {
                            Button(action: {
                                acceptTerms.toggle()
                            }) {
                                Image(systemName: acceptTerms ? "checkmark.square.fill" : "square")
                                    .foregroundColor(acceptTerms ? Color("JapanRed") : .white.opacity(0.7))
                                    .font(.system(size: 20))
                            }

                            Text("I accept the ")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.8))
                            +
                            Text("terms of use")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .underline()

                            Spacer()
                        }
                        .padding(.horizontal, 35)

                        // Register button with liquid glass
                        LiquidGlassButton(action: {
                            registerUser()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Sign up")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(width: 250, height: 55)
                        }
                        .disabled(!isFormValid() || isLoading)
                        .opacity(isFormValid() ? 1.0 : 0.7)
                        .padding(.top, 20)

                        // Login link
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.system(size: 14))

                            Button("Sign in") {
                                dismiss()
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 40)
                    }
                    .padding(.top, 60)
                }
            }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToRegistrationSuccess) {
            RegistrationSuccessView(email: email)
                .navigationBarBackButtonHidden(true)
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func passwordsMatch() -> Bool {
        return password == confirmPassword && !password.isEmpty
    }

    private func isFormValid() -> Bool {
        return !firstName.isEmpty &&
               !lastName.isEmpty &&
               !username.isEmpty &&
               !email.isEmpty &&
               email.contains("@") &&
               password.count >= 8 &&
               passwordsMatch() &&
               acceptTerms
    }

    private func registerUser() {
        isLoading = true

        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false

            if isFormValid() {
                // Navigate directly to success page without alert
                navigateToRegistrationSuccess = true
            } else {
                alertTitle = "Error"
                if !acceptTerms {
                    alertMessage = "Please accept the terms of use"
                } else {
                    alertMessage = "Please fill in all fields correctly"
                }
                showingAlert = true
            }
        }
    }
}

#Preview {
    RegisterView()
}

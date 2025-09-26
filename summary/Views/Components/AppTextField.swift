//
//  AppTextField.swift
//  summary
//

import SwiftUI

enum KeyboardType {
    case `default`
    case emailAddress
    case numberPad
    case phonePad
    case URL
    case namePhonePad
    case twitter
    case webSearch
    case numbersAndPunctuation
    case decimalPad
}

struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboardType: KeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var hasError: Bool = false
    var showToggle: Bool = false
    @Binding var isSecureVisible: Bool

    init(
        placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        isSecure: Bool = false,
        keyboardType: KeyboardType = .default,
        autocapitalization: TextInputAutocapitalization = .sentences,
        hasError: Bool = false,
        showToggle: Bool = false,
        isSecureVisible: Binding<Bool> = .constant(false)
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isSecure = isSecure
        self.keyboardType = keyboardType
        self.autocapitalization = autocapitalization
        self.hasError = hasError
        self.showToggle = showToggle
        self._isSecureVisible = isSecureVisible
    }

    var body: some View {
        HStack {
            // Icon (optional)
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(Color("JapanRed"))
                    .frame(width: 20)
            }

            // Text field
            if isSecure && !isSecureVisible {
                SecureField(placeholder, text: $text)
                    .textInputAutocapitalization(autocapitalization)
                    .foregroundColor(.white)
            } else {
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(autocapitalization)
                    .foregroundColor(.white)
            }

            // Toggle button for secure fields
            if showToggle {
                Button(action: {
                    isSecureVisible.toggle()
                }) {
                    Image(systemName: isSecureVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(Color("JapanRed").opacity(0.7))
                }
            }
        }
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)

                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.3),
                                .white.opacity(0.1),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    hasError ? Color.red.opacity(0.6) : Color.clear,
                    lineWidth: 1.5
                )
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        AppTextField(
            placeholder: "Email",
            text: .constant(""),
            icon: "envelope.fill",
            keyboardType: .emailAddress,
            autocapitalization: .never
        )

        AppTextField(
            placeholder: "Mot de passe",
            text: .constant(""),
            icon: "lock.fill",
            isSecure: true,
            showToggle: true,
            isSecureVisible: .constant(false)
        )

        AppTextField(
            placeholder: "Prénom",
            text: .constant(""),
            icon: "person.fill"
        )
    }
    .padding()
    .background(
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.749, green: 0.188, blue: 0.188),
                Color(red: 0.549, green: 0.088, blue: 0.088)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}

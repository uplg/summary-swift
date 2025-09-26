//
//  LiquidGlassCard.swift
//  summary
//

import SwiftUI

struct LiquidGlassCard<Content: View>: View {
    let content: Content
    let blur: CGFloat
    let opacity: Double
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat

    init(
        blur: CGFloat = 10,
        opacity: Double = 0.8,
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.blur = blur
        self.opacity = opacity
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }

    var body: some View {
        content
            .background(
                ZStack {
                    // Glass background with blur
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .opacity(opacity)

                    // Subtle border glow
                    RoundedRectangle(cornerRadius: cornerRadius)
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
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: .black.opacity(0.1),
                radius: shadowRadius,
                x: 0,
                y: shadowRadius / 2
            )
    }
}

struct LiquidGlassBackground: View {
    let material: Material

    init(material: Material = .ultraThinMaterial) {
        self.material = material
    }

    var body: some View {
        Rectangle()
            .fill(material)
            .ignoresSafeArea()
    }
}

struct LiquidGlassButton<Content: View>: View {
    let action: () -> Void
    let content: Content
    @State private var isPressed = false

    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: action) {
            content
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.regularMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .opacity(isPressed ? 0.8 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onPressGesture(
            onPress: { isPressed = true },
            onRelease: { isPressed = false }
        )
    }
}

extension View {
    func onPressGesture(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }

    func liquidGlassStyle(
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 8
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.1), radius: shadowRadius, x: 0, y: shadowRadius/2)
    }
}
//
//  HomeView.swift
//  summary
//

import SwiftUI

struct HomeView: View {
    @State private var navigateToLogin = false
    
    var body: some View {
        NavigationStack {
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
                            .fill(.white.opacity(0.1))
                            .blur(radius: 60)
                            .frame(width: 200, height: 200)
                            .offset(x: -100, y: -200)
                        
                        Circle()
                            .fill(.white.opacity(0.05))
                            .blur(radius: 80)
                            .frame(width: 300, height: 300)
                            .offset(x: 150, y: 100)
                    }
                }
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Logo with liquid glass effect
                    LiquidGlassCard(blur: 20, opacity: 0.1, cornerRadius: 24, shadowRadius: 12) {
                        VStack(spacing: 20) {
                            Text("Uplg")
                                .font(.system(size: 72, weight: .bold, design: .serif))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .white.opacity(0.8)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
                            
                            Text("SUMMARY")
                                .font(.system(size: 28, weight: .light))
                                .foregroundColor(.white.opacity(0.9))
                                .tracking(6)
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 30)
                    }
                    
                    Spacer()
                    
                    // Liquid glass start button
                    LiquidGlassButton(action: { navigateToLogin = true }) {
                        VStack(spacing: 8) {
                            Text("Commencer")
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 66)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer(minLength: 60)
                }
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}


#Preview {
    HomeView()
}

//
//  YouTubeHomeView.swift
//  summary
//
//  Created by Assistant on 23/09/2025.
//

import SwiftUI
import SwiftData

struct YouTubeHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var processor: YouTubeProcessor
    @State private var youtubeURL = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {               
                // URL Input Section
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("URL de la vidéo YouTube")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("https://www.youtube.com/watch?v=...", text: $youtubeURL)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    Button(action: processVideo) {
                        HStack {
                            if processor.isProcessing {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                            } else {
                                Image(systemName: "waveform.and.mic")
                            }
                            
                            Text(processor.isProcessing ? "Traitement en cours..." : "Transcrire la vidéo")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(youtubeURL.isEmpty || processor.isProcessing ? Color.gray : Color.blue)
                        )
                        .foregroundColor(.white)
                    }
                    .disabled(youtubeURL.isEmpty || processor.isProcessing)
                }
                .padding(.horizontal, 20)
                
                // Processing Status
                if processor.isProcessing {
                    VStack(spacing: 16) {
                        ProgressView(value: processor.progress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .scaleEffect(y: 2)
                        
                        Text(processor.currentStatus)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(processor.progress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal, 20)
                }
                
                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Comment ça marche :")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    InstructionRow(
                        icon: "1.circle.fill",
                        text: "Collez l'URL d'une vidéo YouTube"
                    )
                    
                    InstructionRow(
                        icon: "2.circle.fill",
                        text: "L'audio est extrait et traité localement"
                    )
                    
                    InstructionRow(
                        icon: "3.circle.fill",
                        text: "MLX Whisper génère la transcription"
                    )
                    
                    InstructionRow(
                        icon: "4.circle.fill",
                        text: "Un résumé automatique est créé"
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal, 20)
                
                Spacer(minLength: 50)
            }
        }
        .navigationTitle("Accueil")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Erreur", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func processVideo() {
        guard isValidYouTubeURL(youtubeURL) else {
            alertMessage = "Veuillez entrer une URL YouTube valide"
            showingAlert = true
            return
        }
        
        Task {
            await processor.processYouTubeURL(youtubeURL)
            
            // Vérifier s'il y a eu une erreur
            if let errorMessage = processor.errorMessage {
                alertMessage = "Erreur lors du traitement : \(errorMessage)"
                showingAlert = true
            } else {
                // Réinitialiser le champ URL
                youtubeURL = ""
                
                // Afficher un message de succès
                alertMessage = "Transcription terminée avec succès !"
                showingAlert = true
            }
        }
    }
    
    private func isValidYouTubeURL(_ url: String) -> Bool {
        let youtubePatterns = [
            "youtube.com/watch",
            "youtu.be/",
            "youtube.com/embed/",
            "youtube.com/v/"
        ]
        
        return youtubePatterns.contains { url.contains($0) }
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: VideoTranscription.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = ModelContext(container)
    
    NavigationStack {
        YouTubeHomeView()
            .environmentObject(YouTubeProcessor(modelContext: context))
    }
    .modelContainer(container)
}

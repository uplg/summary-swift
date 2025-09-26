//
//  TranscriptionDetailView.swift
//  summary
//
//  Created by Assistant on 23/09/2025.
//

import SwiftUI

struct TranscriptionDetailView: View {
    let transcription: VideoTranscription
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header avec informations de la vidéo
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(transcription.videoTitle.isEmpty ? "Vidéo YouTube" : transcription.videoTitle)
                                .font(.title2)
                                .fontWeight(.bold)
                                .lineLimit(2)
                            
                            Text(transcription.youtubeURL)
                                .font(.caption)
                                .foregroundColor(.blue)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        StatusBadge(status: transcription.processingStatus)
                    }
                    
                    HStack {
                        if transcription.duration > 0 {
                            Label(transcription.formattedDuration, systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(transcription.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Segmented Control
                Picker("Contenu", selection: $selectedTab) {
                    Text("Résumé").tag(0)
                    Text("Transcription").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Contenu
                TabView(selection: $selectedTab) {
                    // Onglet Résumé
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if transcription.summary.isEmpty {
                                EmptyContentView(
                                    icon: "doc.text",
                                    title: "Résumé non disponible",
                                    message: "Le résumé n'a pas encore été généré ou a échoué."
                                )
                            } else {
                                Text(transcription.summary)
                                    .font(.body)
                                    .lineSpacing(4)
                                    .textSelection(.enabled)
                            }
                        }
                        .padding()
                    }
                    .tag(0)
                    
                    // Onglet Transcription
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if transcription.transcriptionText.isEmpty {
                                EmptyContentView(
                                    icon: "waveform",
                                    title: "Transcription non disponible",
                                    message: "La transcription n'a pas encore été générée ou a échoué."
                                )
                            } else {
                                Text(transcription.transcriptionText)
                                    .font(.body)
                                    .lineSpacing(4)
                                    .textSelection(.enabled)
                            }
                        }
                        .padding()
                    }
                    .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Détails")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(
                        item: shareContent,
                        subject: Text("Transcription YouTube"),
                        message: Text("Transcription de: \(transcription.videoTitle)")
                    ) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    private var shareContent: String {
        var content = "Transcription YouTube\n"
        content += "Titre: \(transcription.videoTitle)\n"
        content += "URL: \(transcription.youtubeURL)\n"
        content += "Date: \(transcription.createdAt.formatted(date: .abbreviated, time: .shortened))\n\n"
        
        if !transcription.summary.isEmpty {
            content += "RÉSUMÉ:\n\(transcription.summary)\n\n"
        }
        
        if !transcription.transcriptionText.isEmpty {
            content += "TRANSCRIPTION COMPLÈTE:\n\(transcription.transcriptionText)"
        }
        
        return content
    }
}

struct EmptyContentView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}

#Preview {
    let sampleTranscription = VideoTranscription(
        youtubeURL: "https://www.youtube.com/watch?v=example",
        videoTitle: "Exemple de vidéo YouTube",
        transcriptionText: "Ceci est un exemple de transcription...",
        summary: "Ceci est un exemple de résumé...",
        duration: 300
    )
    sampleTranscription.processingStatus = .completed
    
    return TranscriptionDetailView(transcription: sampleTranscription)
}
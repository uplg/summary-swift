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
                        Text("YouTube Video URL")
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
                            
                            Text(processor.isProcessing ? "Processing..." : "Transcribe Video")
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
                    Text("How it works:")
                        .font(.headline)
                        .padding(.bottom, 8)
                    
                    InstructionRow(
                        icon: "1.circle.fill",
                        text: "Paste a YouTube video URL"
                    )
                    
                    InstructionRow(
                        icon: "2.circle.fill",
                        text: "Audio is extracted and processed locally"
                    )
                    
                    InstructionRow(
                        icon: "3.circle.fill",
                        text: "MLX Whisper generates the transcription"
                    )
                    
                    InstructionRow(
                        icon: "4.circle.fill",
                        text: "An automatic summary is created"
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
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func processVideo() {
        guard isValidYouTubeURL(youtubeURL) else {
            alertMessage = "Please enter a valid YouTube URL"
            showingAlert = true
            return
        }
        
        Task {
            await processor.processYouTubeURL(youtubeURL)
            
            // Check if there was an error
            if let errorMessage = processor.errorMessage {
                alertMessage = "Processing error: \(errorMessage)"
                showingAlert = true
            } else {
                // Reset URL field
                youtubeURL = ""
                
                // Show success message
                alertMessage = "Transcription completed successfully!"
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

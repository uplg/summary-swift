//
//  TranscriptionDetailView.swift
//  summary
//

import SwiftUI

struct TranscriptionDetailView: View {
    let transcription: VideoTranscription
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with video information
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(transcription.videoTitle.isEmpty ? "YouTube Video" : transcription.videoTitle)
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
                Picker("Content", selection: $selectedTab) {
                    Text("Summary").tag(0)
                    Text("Transcription").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                TabView(selection: $selectedTab) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if transcription.summary.isEmpty {
                                EmptyContentView(
                                    icon: "doc.text",
                                    title: "Summary not available",
                                    message: "The summary has not been generated yet or has failed."
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
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if transcription.transcriptionText.isEmpty {
                                EmptyContentView(
                                    icon: "waveform",
                                    title: "Transcription not available",
                                    message: "The transcription has not been generated yet or has failed."
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
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(
                        item: shareContent,
                        subject: Text("YouTube Transcription"),
                        message: Text("Transcription of: \(transcription.videoTitle)")
                    ) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    
    private var shareContent: String {
        var content = "YouTube Transcription\n"
        content += "Title: \(transcription.videoTitle)\n"
        content += "URL: \(transcription.youtubeURL)\n"
        content += "Date: \(transcription.createdAt.formatted(date: .abbreviated, time: .shortened))\n\n"
        
        if !transcription.summary.isEmpty {
            content += "SUMMARY:\n\(transcription.summary)\n\n"
        }
        
        if !transcription.transcriptionText.isEmpty {
            content += "FULL TRANSCRIPTION:\n\(transcription.transcriptionText)"
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
        videoTitle: "Example YouTube Video",
        transcriptionText: "This is an example transcription...",
        summary: "This is an example summary...",
        duration: 300
    )
    sampleTranscription.processingStatus = .completed
    
    return TranscriptionDetailView(transcription: sampleTranscription)
}
//
//  TranscriptionHistoryView.swift
//  summary
//

import SwiftUI
import SwiftData

struct TranscriptionHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VideoTranscription.createdAt, order: .reverse) 
    private var transcriptions: [VideoTranscription]
    
    @State private var selectedTranscription: VideoTranscription?
    
    var body: some View {
        NavigationStack {
            Group {
                if transcriptions.isEmpty {
                    EmptyHistoryView()
                } else {
                    List {
                        ForEach(transcriptions) { transcription in
                            TranscriptionRowView(transcription: transcription)
                                .onTapGesture {
                                    selectedTranscription = transcription
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button("Delete", role: .destructive) {
                                        deleteTranscription(transcription)
                                    }
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedTranscription) { transcription in
                TranscriptionDetailView(transcription: transcription)
            }
        }
    }
    
    private func deleteTranscription(_ transcription: VideoTranscription) {
        withAnimation {
            modelContext.delete(transcription)
            try? modelContext.save()
        }
    }
}

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No transcriptions")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Your YouTube video transcriptions will appear here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct TranscriptionRowView: View {
    let transcription: VideoTranscription
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(transcription.videoTitle.isEmpty ? "YouTube Video" : transcription.videoTitle)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(transcription.youtubeURL)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    StatusBadge(status: transcription.processingStatus)
                    
                    Text(transcription.createdAt, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            if !transcription.summary.isEmpty {
                Text(transcription.summary)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .padding(.top, 4)
            }
            
            HStack {
                if transcription.duration > 0 {
                    Label(transcription.formattedDuration, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !transcription.transcriptionText.isEmpty {
                    Text("\(transcription.transcriptionText.count) characters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct StatusBadge: View {
    let status: VideoTranscription.ProcessingStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(statusText)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(statusColor.opacity(0.1))
        )
    }
    
    private var statusColor: Color {
        switch status {
        case .pending:
            return .orange
        case .downloading, .transcribing, .summarizing:
            return .blue
        case .completed:
            return .green
        case .failed:
            return .red
        }
    }
    
    private var statusText: String {
        switch status {
        case .pending:
            return "Pending"
        case .downloading:
            return "Downloading"
        case .transcribing:
            return "Transcribing"
        case .summarizing:
            return "Summarizing"
        case .completed:
            return "Completed"
        case .failed:
            return "Failed"
        }
    }
}

#Preview {
    TranscriptionHistoryView()
        .modelContainer(for: VideoTranscription.self, inMemory: true)
}
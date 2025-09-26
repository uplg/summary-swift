//
//  VideoTranscription.swift
//  summary
//

import Foundation
import SwiftData

@Model
final class VideoTranscription {
    var id: UUID
    var youtubeURL: String
    var videoTitle: String
    var transcriptionText: String
    var summary: String
    var createdAt: Date
    var duration: TimeInterval
    var thumbnailURL: String?
    var processingStatus: ProcessingStatus
    
    enum ProcessingStatus: String, Codable, CaseIterable {
        case pending = "pending"
        case downloading = "downloading"
        case transcribing = "transcribing"
        case summarizing = "summarizing"
        case completed = "completed"
        case failed = "failed"
    }
    
    init(youtubeURL: String, videoTitle: String = "", transcriptionText: String = "", summary: String = "", duration: TimeInterval = 0, thumbnailURL: String? = nil) {
        self.id = UUID()
        self.youtubeURL = youtubeURL
        self.videoTitle = videoTitle
        self.transcriptionText = transcriptionText
        self.summary = summary
        self.createdAt = Date()
        self.duration = duration
        self.thumbnailURL = thumbnailURL
        self.processingStatus = .pending
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var isProcessing: Bool {
        return [.pending, .downloading, .transcribing, .summarizing].contains(processingStatus)
    }
}
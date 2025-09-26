//
//  YouTubeExtractor.swift
//  summary
//

import Foundation

class YouTubeExtractor {
    
    enum ExtractionError: Error, LocalizedError {
        case invalidURL
        case networkError(Error)
        case parsingError
        case noAudioStreamFound
        case unsupportedFormat
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid YouTube URL"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .parsingError:
                return "Unable to parse YouTube response"
            case .noAudioStreamFound:
                return "No audio stream found for this video"
            case .unsupportedFormat:
                return "Unsupported video format"
            }
        }
    }
    
    struct VideoInfo: Codable {
        let title: String
        let duration: TimeInterval?
        let thumbnailURL: String?
        let audioStreamURL: String
        let uploader: String?
    }
    
    private let session = URLSession.shared
    
    func extractVideoInfo(from youtubeURL: String) async throws -> VideoInfo {
        guard let cleanURL = cleanYouTubeURL(youtubeURL),
              let url = URL(string: cleanURL) else {
            throw ExtractionError.invalidURL
        }
        
        let htmlContent = try await fetchHTMLContent(from: url)
        let videoInfo = try parseVideoInfo(from: htmlContent, base:youtubeURL)
        
        return videoInfo
    }
    
    private func cleanYouTubeURL(_ urlString: String) -> String? {
        var cleanURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleanURL.contains("youtu.be/") {
            if let videoID = extractVideoID(from: cleanURL) {
                cleanURL = "https://www.youtube.com/watch?v=\(videoID)"
            }
        } else if cleanURL.contains("youtube.com/watch") {
            // Already in the right format
        } else if cleanURL.contains("youtube.com/embed/") {
            if let videoID = extractVideoID(from: cleanURL) {
                cleanURL = "https://www.youtube.com/watch?v=\(videoID)"
            }
        } else {
            return nil
        }
        
        return cleanURL
    }
    
    private func extractVideoID(from urlString: String) -> String? {
        if urlString.contains("youtu.be/") {
            let components = urlString.components(separatedBy: "youtu.be/")
            if components.count > 1 {
                let videoID = components[1].components(separatedBy: "?")[0]
                return videoID
            }
        } else if urlString.contains("youtube.com/watch?v=") {
            let components = urlString.components(separatedBy: "v=")
            if components.count > 1 {
                let videoID = components[1].components(separatedBy: "&")[0]
                return videoID
            }
        } else if urlString.contains("youtube.com/embed/") {
            let components = urlString.components(separatedBy: "embed/")
            if components.count > 1 {
                let videoID = components[1].components(separatedBy: "?")[0]
                return videoID
            }
        }
        return nil
    }
    
    private func fetchHTMLContent(from url: URL) async throws -> String {
        do {
            let (data, _) = try await session.data(from: url)
            guard let htmlContent = String(data: data, encoding: .utf8) else {
                throw ExtractionError.parsingError
            }
            return htmlContent
        } catch {
            throw ExtractionError.networkError(error)
        }
    }
    
    private func parseVideoInfo(from htmlContent: String, base youtubeURL: String) throws -> VideoInfo {
        let title = extractTitle(from: htmlContent) ?? "Vidéo YouTube"
        let duration = extractDuration(from: htmlContent)
        let thumbnailURL = extractThumbnailURL(from: htmlContent)
        let uploader = extractUploader(from: htmlContent)
        
        guard let audioStreamURL = extractAudioStreamURL(from: htmlContent, base: youtubeURL) else {
            throw ExtractionError.noAudioStreamFound
        }
        
        return VideoInfo(
            title: title,
            duration: duration,
            thumbnailURL: thumbnailURL,
            audioStreamURL: audioStreamURL,
            uploader: uploader
        )
    }
    
    private func extractTitle(from htmlContent: String) -> String? {
        if let titleMatch = htmlContent.range(of: #"<meta property="og:title" content="([^"]*)"#, options: .regularExpression) {
            let titleString = String(htmlContent[titleMatch])
            if let contentMatch = titleString.range(of: #"content="([^"]*)"#, options: .regularExpression) {
                let content = String(titleString[contentMatch])
                let title = content.replacingOccurrences(of: #"content=""#, with: "").replacingOccurrences(of: #"""#, with: "")
                return title.isEmpty ? nil : title
            }
        }
        
        if let titleMatch = htmlContent.range(of: #"<title>([^<]*)</title>"#, options: .regularExpression) {
            let titleString = String(htmlContent[titleMatch])
            let title = titleString.replacingOccurrences(of: "<title>", with: "").replacingOccurrences(of: "</title>", with: "")
            return title.isEmpty ? nil : title
        }
        
        return nil
    }
    
    private func extractDuration(from htmlContent: String) -> TimeInterval? {
        // Chercher dans les métadonnées
        if let durationMatch = htmlContent.range(of: #""lengthSeconds":"(\d+)""#, options: .regularExpression) {
            let durationString = String(htmlContent[durationMatch])
            if let secondsString = durationString.components(separatedBy: ":").last?.replacingOccurrences(of: "\"", with: ""),
               let seconds = Double(secondsString) {
                return seconds
            }
        }
        return nil
    }
    
    private func extractThumbnailURL(from htmlContent: String) -> String? {
        if let thumbnailMatch = htmlContent.range(of: #"<meta property="og:image" content="([^"]*)"#, options: .regularExpression) {
            let thumbnailString = String(htmlContent[thumbnailMatch])
            if let contentMatch = thumbnailString.range(of: #"content="([^"]*)"#, options: .regularExpression) {
                let content = String(thumbnailString[contentMatch])
                let thumbnailURL = content.replacingOccurrences(of: #"content=""#, with: "").replacingOccurrences(of: #"""#, with: "")
                return thumbnailURL.isEmpty ? nil : thumbnailURL
            }
        }
        return nil
    }
    
    private func extractUploader(from htmlContent: String) -> String? {
        if let uploaderMatch = htmlContent.range(of: #""ownerChannelName":"([^"]*)"#, options: .regularExpression) {
            let uploaderString = String(htmlContent[uploaderMatch])
            if let nameMatch = uploaderString.range(of: #":"([^"]*)"#, options: .regularExpression) {
                let name = String(uploaderString[nameMatch])
                let uploader = name.replacingOccurrences(of: ":\"", with: "").replacingOccurrences(of: "\"", with: "")
                return uploader.isEmpty ? nil : uploader
            }
        }
        return nil
    }
    
    private func extractAudioStreamURL(from htmlContent: String, base youtubeURL: String) -> String? {
        return "http://localhost:8000/extract-audio?url="+youtubeURL
    }
}

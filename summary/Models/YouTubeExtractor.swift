//
//  YouTubeExtractor.swift
//  summary
//
//  Created by Assistant on 25/09/2025.
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
                return "URL YouTube invalide"
            case .networkError(let error):
                return "Erreur réseau: \(error.localizedDescription)"
            case .parsingError:
                return "Impossible d'analyser la réponse YouTube"
            case .noAudioStreamFound:
                return "Aucun flux audio trouvé pour cette vidéo"
            case .unsupportedFormat:
                return "Format de vidéo non supporté"
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
    
    /// Extrait les informations et l'URL audio d'une vidéo YouTube
    func extractVideoInfo(from youtubeURL: String) async throws -> VideoInfo {
        // Valider et nettoyer l'URL
        guard let cleanURL = cleanYouTubeURL(youtubeURL),
              let url = URL(string: cleanURL) else {
            throw ExtractionError.invalidURL
        }
        
        // Récupérer la page YouTube
        let htmlContent = try await fetchHTMLContent(from: url)
        
        // Extraire les informations de la vidéo
        let videoInfo = try parseVideoInfo(from: htmlContent, base:youtubeURL)
        
        return videoInfo
    }
    
    /// Nettoie et normalise l'URL YouTube
    private func cleanYouTubeURL(_ urlString: String) -> String? {
        var cleanURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Gérer différents formats d'URL YouTube
        if cleanURL.contains("youtu.be/") {
            // Format court: https://youtu.be/VIDEO_ID
            if let videoID = extractVideoID(from: cleanURL) {
                cleanURL = "https://www.youtube.com/watch?v=\(videoID)"
            }
        } else if cleanURL.contains("youtube.com/watch") {
            // Format standard: https://www.youtube.com/watch?v=VIDEO_ID
            // Déjà dans le bon format
        } else if cleanURL.contains("youtube.com/embed/") {
            // Format embed: https://www.youtube.com/embed/VIDEO_ID
            if let videoID = extractVideoID(from: cleanURL) {
                cleanURL = "https://www.youtube.com/watch?v=\(videoID)"
            }
        } else {
            return nil
        }
        
        return cleanURL
    }
    
    /// Extrait l'ID de la vidéo depuis différents formats d'URL
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
    
    /// Récupère le contenu HTML de la page YouTube
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
    
    /// Parse les informations de la vidéo depuis le HTML
    private func parseVideoInfo(from htmlContent: String, base youtubeURL: String) throws -> VideoInfo {
        // Extraire le titre
        let title = extractTitle(from: htmlContent) ?? "Vidéo YouTube"
        
        // Extraire la durée
        let duration = extractDuration(from: htmlContent)
        
        // Extraire l'URL de la miniature
        let thumbnailURL = extractThumbnailURL(from: htmlContent)
        
        // Extraire l'uploader
        let uploader = extractUploader(from: htmlContent)
        
        // Extraire l'URL du flux audio
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
    
    /// Extrait le titre de la vidéo
    private func extractTitle(from htmlContent: String) -> String? {
        // Chercher dans les métadonnées og:title
        if let titleMatch = htmlContent.range(of: #"<meta property="og:title" content="([^"]*)"#, options: .regularExpression) {
            let titleString = String(htmlContent[titleMatch])
            if let contentMatch = titleString.range(of: #"content="([^"]*)"#, options: .regularExpression) {
                let content = String(titleString[contentMatch])
                let title = content.replacingOccurrences(of: #"content=""#, with: "").replacingOccurrences(of: #"""#, with: "")
                return title.isEmpty ? nil : title
            }
        }
        
        // Fallback: chercher dans le title tag
        if let titleMatch = htmlContent.range(of: #"<title>([^<]*)</title>"#, options: .regularExpression) {
            let titleString = String(htmlContent[titleMatch])
            let title = titleString.replacingOccurrences(of: "<title>", with: "").replacingOccurrences(of: "</title>", with: "")
            return title.isEmpty ? nil : title
        }
        
        return nil
    }
    
    /// Extrait la durée de la vidéo
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
    
    /// Extrait l'URL de la miniature
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
    
    /// Extrait le nom de l'uploader
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
    
    /// Extrait l'URL du flux audio
    private func extractAudioStreamURL(from htmlContent: String, base youtubeURL: String) -> String? {
        return "http://localhost:8000/extract-audio?url="+youtubeURL
    }
}

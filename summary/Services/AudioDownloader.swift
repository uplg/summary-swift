//
//  AudioDownloader.swift
//  summary
//
//  Created by Assistant on 25/09/2025.
//

import Foundation
import Combine

class AudioDownloader: NSObject, ObservableObject {
    
    enum DownloadError: Error, LocalizedError {
        case invalidURL
        case networkError(Error)
        case fileSystemError(Error)
        case downloadCancelled
        case noData
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "URL audio invalide"
            case .networkError(let error):
                return "Erreur de téléchargement: \(error.localizedDescription)"
            case .fileSystemError(let error):
                return "Erreur de fichier: \(error.localizedDescription)"
            case .downloadCancelled:
                return "Téléchargement annulé"
            case .noData:
                return "Aucune donnée reçue"
            }
        }
    }
    
    struct DownloadProgress {
        let bytesDownloaded: Int64
        let totalBytes: Int64
        let percentage: Double
        
        init(bytesDownloaded: Int64, totalBytes: Int64) {
            self.bytesDownloaded = bytesDownloaded
            self.totalBytes = totalBytes
            self.percentage = totalBytes > 0 ? Double(bytesDownloaded) / Double(totalBytes) : 0.0
        }
    }
    
    @Published var downloadProgress: DownloadProgress?
    @Published var isDownloading = false
    
    private var downloadTask: URLSessionDownloadTask?
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300 // 5 minutes
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    /// Télécharge un fichier audio depuis une URL
    func downloadAudio(from urlString: String, to destinationURL: URL) async throws -> URL {
        guard let url = URL(string: urlString) else {
            throw DownloadError.invalidURL
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                self.isDownloading = true
                self.downloadProgress = nil
            }
            
            downloadTask = urlSession.downloadTask(with: url) { [weak self] tempURL, response, error in
                DispatchQueue.main.async {
                    self?.isDownloading = false
                    self?.downloadProgress = nil
                }
                
                if let error = error {
                    continuation.resume(throwing: DownloadError.networkError(error))
                    return
                }
                
                guard let tempURL = tempURL else {
                    continuation.resume(throwing: DownloadError.noData)
                    return
                }
                
                do {
                    // Créer le répertoire de destination si nécessaire
                    let destinationDirectory = destinationURL.deletingLastPathComponent()
                    try FileManager.default.createDirectory(at: destinationDirectory, withIntermediateDirectories: true)
                    
                    // Supprimer le fichier existant s'il y en a un
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    
                    // Déplacer le fichier temporaire vers la destination finale
                    try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                    
                    continuation.resume(returning: destinationURL)
                } catch {
                    continuation.resume(throwing: DownloadError.fileSystemError(error))
                }
            }
            
            downloadTask?.resume()
        }
    }
    
    /// Annule le téléchargement en cours
    func cancelDownload() {
        downloadTask?.cancel()
        downloadTask = nil
        
        DispatchQueue.main.async {
            self.isDownloading = false
            self.downloadProgress = nil
        }
    }
    
    /// Génère un nom de fichier unique pour l'audio
    func generateAudioFileName(for videoTitle: String) -> String {
        // Nettoyer le titre pour le nom de fichier
        let cleanTitle = videoTitle
            .replacingOccurrences(of: "[^a-zA-Z0-9\\s-_]", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: "_", options: .regularExpression)
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileName = "\(cleanTitle)_\(timestamp).mp3"
        
        return fileName
    }
    
    /// Obtient l'URL du répertoire de téléchargement
    func getDownloadsDirectory() throws -> URL {
        let documentsDirectory = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let downloadsDirectory = documentsDirectory.appendingPathComponent("Downloads")
        
        // Créer le répertoire s'il n'existe pas
        if !FileManager.default.fileExists(atPath: downloadsDirectory.path) {
            try FileManager.default.createDirectory(at: downloadsDirectory, withIntermediateDirectories: true)
        }
        
        return downloadsDirectory
    }
    
    /// Vérifie si un fichier audio existe déjà
    func audioFileExists(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    /// Obtient la taille d'un fichier
    func getFileSize(at url: URL) -> Int64? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64
        } catch {
            return nil
        }
    }
    
    /// Supprime un fichier audio
    func deleteAudioFile(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
}

// MARK: - URLSessionDownloadDelegate
extension AudioDownloader: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = DownloadProgress(
            bytesDownloaded: totalBytesWritten,
            totalBytes: totalBytesExpectedToWrite
        )
        
        DispatchQueue.main.async {
            self.downloadProgress = progress
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // Cette méthode est gérée dans la completion du downloadTask
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            DispatchQueue.main.async {
                self.isDownloading = false
                self.downloadProgress = nil
            }
        }
    }
}
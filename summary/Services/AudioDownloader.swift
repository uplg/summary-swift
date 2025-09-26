//
//  AudioDownloader.swift
//  summary
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
                return "Invalid audio URL"
            case .networkError(let error):
                return "Download error: \(error.localizedDescription)"
            case .fileSystemError(let error):
                return "File error: \(error.localizedDescription)"
            case .downloadCancelled:
                return "Download cancelled"
            case .noData:
                return "No data received"
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
        config.timeoutIntervalForResource = 300
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
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
                    let destinationDirectory = destinationURL.deletingLastPathComponent()
                    try FileManager.default.createDirectory(at: destinationDirectory, withIntermediateDirectories: true)
                    
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    
                    try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                    
                    continuation.resume(returning: destinationURL)
                } catch {
                    continuation.resume(throwing: DownloadError.fileSystemError(error))
                }
            }
            
            downloadTask?.resume()
        }
    }
    
    func cancelDownload() {
        downloadTask?.cancel()
        downloadTask = nil
        
        DispatchQueue.main.async {
            self.isDownloading = false
            self.downloadProgress = nil
        }
    }
    
    func generateAudioFileName(for videoTitle: String) -> String {
        let cleanTitle = videoTitle
            .replacingOccurrences(of: "[^a-zA-Z0-9\\s-_]", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: "_", options: .regularExpression)
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileName = "\(cleanTitle)_\(timestamp).mp3"
        
        return fileName
    }
    
    func getDownloadsDirectory() throws -> URL {
        let documentsDirectory = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let downloadsDirectory = documentsDirectory.appendingPathComponent("Downloads")
        
        if !FileManager.default.fileExists(atPath: downloadsDirectory.path) {
            try FileManager.default.createDirectory(at: downloadsDirectory, withIntermediateDirectories: true)
        }
        
        return downloadsDirectory
    }
    
    func audioFileExists(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func getFileSize(at url: URL) -> Int64? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64
        } catch {
            return nil
        }
    }
    
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
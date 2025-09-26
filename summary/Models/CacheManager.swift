import Foundation

class CacheManager {
    static let shared = CacheManager()
    
    private let userDefaults = UserDefaults.standard
    private let videoInfoCacheKey = "videoInfoCache"
    private let transcriptionCacheKey = "transcriptionCache"
    
    private init() {}
    
    // MARK: - VideoInfo Cache
    
    func getCachedVideoInfo(for urlString: String) -> YouTubeExtractor.VideoInfo? {
        guard let data = userDefaults.data(forKey: "\(videoInfoCacheKey)_\(urlString.hashValue)"),
              let videoInfo = try? JSONDecoder().decode(YouTubeExtractor.VideoInfo.self, from: data) else {
            return nil
        }
        return videoInfo
    }
    
    func setCachedVideoInfo(_ videoInfo: YouTubeExtractor.VideoInfo, for urlString: String) {
        guard let data = try? JSONEncoder().encode(videoInfo) else { return }
        userDefaults.set(data, forKey: "\(videoInfoCacheKey)_\(urlString.hashValue)")
    }
    
    // MARK: - Transcription Cache
    
    func getCachedTranscription(for urlString: String) -> String? {
        return userDefaults.string(forKey: "\(transcriptionCacheKey)_\(urlString.hashValue)")
    }
    
    func setCachedTranscription(_ transcription: String, for urlString: String) {
        userDefaults.set(transcription, forKey: "\(transcriptionCacheKey)_\(urlString.hashValue)")
    }
    
    // MARK: - Cache Management
    
    func clearAllCache() {
        let allKeys = userDefaults.dictionaryRepresentation().keys
        
        for key in allKeys {
            if key.hasPrefix(videoInfoCacheKey) || key.hasPrefix(transcriptionCacheKey) {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
    
    func clearCache(for urlString: String) {
        let hashValue = urlString.hashValue
        userDefaults.removeObject(forKey: "\(videoInfoCacheKey)_\(hashValue)")
        userDefaults.removeObject(forKey: "\(transcriptionCacheKey)_\(hashValue)")
    }
    
    // MARK: - Cache Statistics & Management
    
    func getCacheSize() -> (videoInfoCount: Int, transcriptionCount: Int) {
        let allKeys = userDefaults.dictionaryRepresentation().keys
        
        let videoInfoCount = allKeys.filter { $0.hasPrefix(videoInfoCacheKey) }.count
        let transcriptionCount = allKeys.filter { $0.hasPrefix(transcriptionCacheKey) }.count
        
        return (videoInfoCount, transcriptionCount)
    }
    
    func getCacheMemoryUsage() -> Int {
        let allKeys = userDefaults.dictionaryRepresentation().keys
        var totalSize = 0
        
        for key in allKeys {
            if key.hasPrefix(videoInfoCacheKey) || key.hasPrefix(transcriptionCacheKey) {
                if let data = userDefaults.data(forKey: key) {
                    totalSize += data.count
                } else if let string = userDefaults.string(forKey: key) {
                    totalSize += string.utf8.count
                }
            }
        }
        
        return totalSize
    }
    
    func cleanOldCache(olderThanDays days: Int = 30) {
        let allKeys = userDefaults.dictionaryRepresentation().keys
        
        for key in allKeys {
            if key.hasPrefix(videoInfoCacheKey) || key.hasPrefix(transcriptionCacheKey) {
                continue
            }
        }
        
        let maxCacheSize = 50 * 1024 * 1024 // 50MB
        if getCacheMemoryUsage() > maxCacheSize {
            clearOldestEntries(keepCount: 20)
        }
    }
    
    private func clearOldestEntries(keepCount: Int) {
        let allKeys = userDefaults.dictionaryRepresentation().keys
        let cacheKeys = allKeys.filter { $0.hasPrefix(videoInfoCacheKey) || $0.hasPrefix(transcriptionCacheKey) }
        
        if cacheKeys.count > keepCount {
            let keysToRemove = Array(cacheKeys.dropFirst(keepCount))
            for key in keysToRemove {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
}

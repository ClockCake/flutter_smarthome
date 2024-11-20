//
//  CacheManager.swift
//  JiJiaHuiClient
//
//  Created by huangyaodong on 2024/9/12.
//

import Foundation

class CacheManager {
    static let shared = CacheManager()
    
    private init() {}
    
    // 获取缓存目录
    private var cacheDirectory: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    // 获取缓存大小
    func getCacheSize() -> Int64 {
        let enumerator = FileManager.default.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey], options: [])
        var size: Int64 = 0
        
        while let fileURL = enumerator?.nextObject() as? URL {
            guard let attributes = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                  let fileSize = attributes.fileSize else { continue }
            size += Int64(fileSize)
        }
        
        return size
    }
    // 获取人类可读的缓存大小
    func getReadableCacheSize() -> String {
        let bytes = Double(getCacheSize())
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    // 清理缓存
    func clearCache() {
        let enumerator = FileManager.default.enumerator(at: cacheDirectory, includingPropertiesForKeys: nil)
        
        while let fileURL = enumerator?.nextObject() as? URL {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
}

// 使用示例
// let cacheSize = CacheManager.shared.getCacheSize()
// print("Cache size: \(cacheSize) bytes")
// CacheManager.shared.clearCache()

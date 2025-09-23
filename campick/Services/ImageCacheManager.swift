//
//  ImageCacheManager.swift
//  campick
//
//  Created by 호집 on 9/23/25.
//

import Foundation

final class ImageCacheManager {
    static let shared = ImageCacheManager()

    private init() {
        setupURLCache()
    }

    private func setupURLCache() {
        // 메모리 캐시: 50MB
        let memoryCapacity = 50 * 1024 * 1024
        // 디스크 캐시: 200MB
        let diskCapacity = 200 * 1024 * 1024

        let urlCache = URLCache(
            memoryCapacity: memoryCapacity,
            diskCapacity: diskCapacity,
            diskPath: "ImageCache"
        )

        URLCache.shared = urlCache
    }

    func clearCache() {
        URLCache.shared.removeAllCachedResponses()
    }

    func cacheSize() -> Int {
        return URLCache.shared.currentMemoryUsage + URLCache.shared.currentDiskUsage
    }
}
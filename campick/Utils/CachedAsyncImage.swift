//
//  CachedAsyncImage.swift
//  campick
//
//  Created by 호집 on 9/23/25.
//

import SwiftUI
import UIKit

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @StateObject private var loader = ImageLoader()

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = loader.image {
                content(Image(uiImage: image))
            } else {
                placeholder()
            }
        }
        .onAppear {
            loader.load(from: url)
        }
        .onChange(of: url) { _, newURL in
            loader.load(from: newURL)
        }
    }
}

// UIImage만 받는 간단한 버전
extension CachedAsyncImage where Content == Image, Placeholder == Color {
    init(url: URL?) {
        self.init(
            url: url,
            content: { $0.resizable() },
            placeholder: { Color.gray.opacity(0.3) }
        )
    }
}

@MainActor
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var currentURL: URL?

    func load(from url: URL?) {
        guard let url = url, url != currentURL else { return }

        // Validate URL scheme
        guard url.scheme == "http" || url.scheme == "https" else {
            print("CachedAsyncImage: Invalid URL scheme: \(url)")
            return
        }

        currentURL = url

        // 메모리 캐시에서 먼저 확인 (동기)
        if let cachedImage = ImageCache.shared.getImage(for: url) {
            self.image = cachedImage
            return
        }

        Task {
            // 디스크 캐시에서 확인
            if let diskImage = await ImageCache.shared.getDiskImage(for: url) {
                await MainActor.run {
                    if self.currentURL == url {
                        self.image = diskImage
                        ImageCache.shared.setImage(diskImage, for: url) // 메모리에도 저장
                    }
                }
                return
            }

            // 네트워크에서 다운로드
            await downloadImage(from: url)
        }
    }

    private func downloadImage(from url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data) else { return }

            await MainActor.run {
                if self.currentURL == url { // URL이 바뀌지 않았는지 확인
                    self.image = uiImage
                    ImageCache.shared.setImage(uiImage, for: url)
                }
            }

            await ImageCache.shared.saveToDisk(uiImage, for: url)
        } catch {
            print("CachedAsyncImage: Failed to load image from \(url): \(error.localizedDescription)")
        }
    }
}

@MainActor
class ImageCache {
    static let shared = ImageCache()

    private var memoryCache: [URL: UIImage] = [:]
    private let maxMemoryItems = 100

    private init() {}

    func getImage(for url: URL) -> UIImage? {
        return memoryCache[url]
    }

    func setImage(_ image: UIImage, for url: URL) {
        // 메모리 캐시 크기 제한
        if memoryCache.count >= maxMemoryItems {
            // 가장 오래된 항목 제거 (간단한 LRU)
            if let firstKey = memoryCache.keys.first {
                memoryCache.removeValue(forKey: firstKey)
            }
        }
        memoryCache[url] = image
    }

    func getDiskImage(for url: URL) async -> UIImage? {
        let filename = url.absoluteString.hashValue.description
        let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let filePath = documentsPath.appendingPathComponent("ImageCache").appendingPathComponent(filename)

        guard let data = try? Data(contentsOf: filePath),
              let image = UIImage(data: data) else {
            return nil
        }

        return image
    }

    func saveToDisk(_ image: UIImage, for url: URL) async {
        let filename = url.absoluteString.hashValue.description
        let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let cacheDir = documentsPath.appendingPathComponent("ImageCache")

        // 캐시 디렉토리 생성
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)

        let filePath = cacheDir.appendingPathComponent(filename)

        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: filePath)
        }
    }

    func clearCache() {
        memoryCache.removeAll()

        let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let cacheDir = documentsPath.appendingPathComponent("ImageCache")
        try? FileManager.default.removeItem(at: cacheDir)
    }
}
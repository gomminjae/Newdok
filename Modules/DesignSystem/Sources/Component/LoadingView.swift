//
//  LoadingView.swift
//  DesignSystem
//
//  Created by 권민재 on 8/7/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import SwiftUI
import Shared
import ImageIO

public struct LoadingView: View {
    public init() {}

    public var body: some View {
        GIFImageView(gifName: "load")
            .frame(width: 50, height: 50)
            .accessibilityLabel("로딩 중")
            .accessibilityIdentifier(AccessibilityID.DesignSystem.loadingView)
            .accessibilityAddTraits(.updatesFrequently)
    }
}

private struct GIFImageView: UIViewRepresentable {
    let gifName: String

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        // 동기적으로 캐시에서 가져와서 애니메이션 시작
        if let (frames, duration) = GIFCache.shared.framesAndDuration(for: gifName) {
            imageView.animationImages = frames
            imageView.animationDuration = duration
            imageView.startAnimating()
        }

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // 필요 시 애니메이션 중지/다시 시작 등 처리
    }
}

/// 싱글톤 캐시로, 한 번만 GIF를 디코딩하고 재사용 (NSLock으로 thread-safe)
private final class GIFCache: @unchecked Sendable {
    static let shared = GIFCache()
    private var cache: [String: (frames: [UIImage], duration: TimeInterval)] = [:]
    private let lock = NSLock()
    private init() {}

    func framesAndDuration(for name: String) -> (frames: [UIImage], duration: TimeInterval)? {
        lock.lock()
        if let entry = cache[name] {
            lock.unlock()
            return entry
        }
        lock.unlock()

        guard
            let url = Bundle.module.url(forResource: name, withExtension: "gif"),
            let data = try? Data(contentsOf: url),
            let source = CGImageSourceCreateWithData(data as CFData, nil)
        else { return nil }

        let count = CGImageSourceGetCount(source)
        var frames: [UIImage] = []
        var total: TimeInterval = 0

        for i in 0..<count {
            if let cg = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let delay = GIFCache.delay(at: i, source: source)
                frames.append(UIImage(cgImage: cg))
                total += delay
            }
        }

        let entry = (frames: frames, duration: total)
        lock.lock()
        cache[name] = entry
        lock.unlock()
        return entry
    }

    private static func delay(at index: Int, source: CGImageSource) -> TimeInterval {
        let defaultDelay = 0.1
        guard
            let props = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
            let gifProps = props[kCGImagePropertyGIFDictionary] as? [CFString: Any],
            let raw = gifProps[kCGImagePropertyGIFUnclampedDelayTime] as? Double
                     ?? gifProps[kCGImagePropertyGIFDelayTime] as? Double
        else {
            return defaultDelay
        }
        return raw < 0.011 ? defaultDelay : raw
    }
}

#Preview {
    VStack(spacing: 20) {
        LoadingView()
    }
    .padding()
    .background(Color.bgSystem)
}

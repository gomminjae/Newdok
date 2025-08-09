//
//  LoadingView.swift
//  DesignSystem
//
//  Created by 권민재 on 8/7/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import SwiftUI
import ImageIO

public struct LoadingView: View {
    public init() {}

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { _ in
                GIFImageView(gifName: "load")
                    
            }
        }
    }
}

private struct GIFImageView: UIViewRepresentable {
    let gifName: String

    func makeUIView(context: Context) -> UIView {
        // 1. 투명한 컨테이너 생성
        let container = UIView()
        container.backgroundColor = .clear

        // 2. 실제 GIF 애니메이션을 재생할 UIImageView
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // 3. 컨테이너에 추가하고, 모든 엣지에 제약 걸기
        container.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])

        // 4. 캐시된 프레임 가져와서 애니메이션 시작
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

/// 싱글톤 캐시로, 한 번만 GIF를 디코딩하고 재사용
private class GIFCache {
    static let shared = GIFCache()
    private var cache: [String: (frames: [UIImage], duration: TimeInterval)] = [:]
    private init() {}

    func framesAndDuration(for name: String) -> (frames: [UIImage], duration: TimeInterval)? {
        if let entry = cache[name] { return entry }

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
        cache[name] = entry
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
    .background(Color(hex: "#F5F5F7"))
}

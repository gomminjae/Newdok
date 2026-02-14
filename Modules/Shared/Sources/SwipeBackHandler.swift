//
//  SwipeBackHandler.swift
//  Shared
//
//  Created by 권민재 on 8/7/25.
//

import SwiftUI
import UIKit

// MARK: - SwiftUI Swipe Back Gesture
public extension View {
    /// 커스텀 네비게이션 바를 사용하면서도 swipe back 제스처를 활성화합니다.
    /// - Parameter edgeOnly: true면 화면 왼쪽 가장자리(30pt)에서만 스와이프 백 허용
    func enableSwipeBack(edgeOnly: Bool = false) -> some View {
        self.background(SwipeBackEnabler(edgeOnly: edgeOnly))
    }
}

// MARK: - Swipe Back Enabler
private struct SwipeBackEnabler: UIViewControllerRepresentable {
    let edgeOnly: Bool

    func makeUIViewController(context: Context) -> SwipeBackEnablerVC {
        SwipeBackEnablerVC(edgeOnly: edgeOnly)
    }

    func updateUIViewController(_ uiViewController: SwipeBackEnablerVC, context: Context) {
        uiViewController.edgeOnly = edgeOnly
    }
}

private class SwipeBackEnablerVC: UIViewController, UIGestureRecognizerDelegate {
    var edgeOnly: Bool

    init(edgeOnly: Bool) {
        self.edgeOnly = edgeOnly
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.edgeOnly = false
        super.init(coder: coder)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupGesture()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupGesture()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGesture()
    }

    private func setupGesture() {
        guard let nav = navigationController else { return }

        if nav.interactivePopGestureRecognizer?.delegate !== self {
            nav.interactivePopGestureRecognizer?.delegate = self
        }
        nav.interactivePopGestureRecognizer?.isEnabled = true
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let nav = navigationController else { return false }

        // 스택에 2개 이상 있을 때만 pop 허용
        if nav.viewControllers.count <= 1 {
            return false
        }

        // edgeOnly가 true면 화면 왼쪽 가장자리(30pt)에서만 허용
        if edgeOnly {
            let location = gestureRecognizer.location(in: gestureRecognizer.view)
            return location.x < 30
        }

        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

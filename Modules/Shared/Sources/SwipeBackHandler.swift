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
    func enableSwipeBack(edgeOnly: Bool = false) -> some View {
        self.background(SwipeBackEnabler())
    }
}

// MARK: - Swipe Back Enabler
private struct SwipeBackEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SwipeBackEnablerVC {
        SwipeBackEnablerVC()
    }

    func updateUIViewController(_ uiViewController: SwipeBackEnablerVC, context: Context) {}
}

private class SwipeBackEnablerVC: UIViewController, UIGestureRecognizerDelegate {

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
        return nav.viewControllers.count > 1
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

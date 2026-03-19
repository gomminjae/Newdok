//
//  SwipeBackHandler.swift
//  Shared
//
//  Created by 권민재 on 8/7/25.
//

import SwiftUI
import UIKit

// MARK: - 시스템 스와이프백 활성화
public extension View {
    /// navigationBarHidden 상태에서도 시스템 스와이프백 제스처를 활성화합니다.
    func enableSwipeBack() -> some View {
        self.background(SystemPopGestureEnabler())
    }

    /// 스와이프백 제스처를 조건부로 비활성화합니다.
    func swipeBackDisabled(_ disabled: Bool) -> some View {
        self.background(PopGestureToggle(disabled: disabled))
    }

    /// iOS 26+ full-width 스와이프백만 비활성화합니다. (edge pop은 유지)
    func swipeBackFullWidthDisabled(_ disabled: Bool) -> some View {
        self.background(FullWidthPopGestureToggle(disabled: disabled))
    }
}

// MARK: - 시스템 Pop 제스처 활성화 (delegate = nil)
private struct SystemPopGestureEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        PopGestureEnablerVC()
    }
    func updateUIViewController(_ vc: UIViewController, context: Context) {}
}

private class PopGestureEnablerVC: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let nav = navigationController else { return }
        nav.interactivePopGestureRecognizer?.delegate = nil
        nav.interactivePopGestureRecognizer?.isEnabled = true
        if #available(iOS 26.0, *) {
            nav.interactiveContentPopGestureRecognizer?.isEnabled = true
        }
    }
}

// MARK: - 스와이프백 조건부 비활성화
private struct PopGestureToggle: UIViewControllerRepresentable {
    let disabled: Bool

    func makeUIViewController(context: Context) -> PopGestureToggleVC {
        PopGestureToggleVC(disabled: disabled)
    }

    func updateUIViewController(_ vc: PopGestureToggleVC, context: Context) {
        vc.disabled = disabled
        vc.updateGesture()
    }
}

// MARK: - iOS 26+ full-width pop만 비활성화 (edge pop 유지)
private struct FullWidthPopGestureToggle: UIViewControllerRepresentable {
    let disabled: Bool

    func makeUIViewController(context: Context) -> FullWidthPopGestureToggleVC {
        FullWidthPopGestureToggleVC(disabled: disabled)
    }

    func updateUIViewController(_ vc: FullWidthPopGestureToggleVC, context: Context) {
        vc.disabled = disabled
        vc.updateGesture()
    }
}

private class FullWidthPopGestureToggleVC: UIViewController {
    var disabled: Bool

    init(disabled: Bool) {
        self.disabled = disabled
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.disabled = false
        super.init(coder: coder)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateGesture()
    }

    func updateGesture() {
        guard let nav = navigationController else { return }
        if #available(iOS 26.0, *) {
            nav.interactiveContentPopGestureRecognizer?.isEnabled = !disabled
        }
    }
}

private class PopGestureToggleVC: UIViewController {
    var disabled: Bool

    init(disabled: Bool) {
        self.disabled = disabled
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.disabled = false
        super.init(coder: coder)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateGesture()
    }

    func updateGesture() {
        guard let nav = navigationController else { return }
        nav.interactivePopGestureRecognizer?.isEnabled = !disabled
        if #available(iOS 26.0, *) {
            nav.interactiveContentPopGestureRecognizer?.isEnabled = !disabled
        }
    }
}

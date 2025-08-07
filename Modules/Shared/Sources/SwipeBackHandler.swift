//
//  SwipeBackHandler.swift
//  Shared
//
//  Created by 권민재 on 8/7/25.
//



import SwiftUI

public extension View {
    func enableSwipeBack() -> some View {
        self
            .background(
                SwipeBackHandler()
            )
    }
}

private struct SwipeBackHandler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            if let navigationController = uiViewController.navigationController {
                navigationController.interactivePopGestureRecognizer?.isEnabled = true
                navigationController.interactivePopGestureRecognizer?.delegate = nil
            }
        }
    }
}
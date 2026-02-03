//
//  AppConstants.swift
//  Shared
//
//  Created by 권민재 on 2/3/26.
//

import Foundation

public enum AppConstants {
    public enum Duration {
        /// Splash 화면 표시 시간
        public static let splash: TimeInterval = 1.5

        /// Toast 메시지 자동 숨김 시간
        public static let toast: TimeInterval = 2.5
    }

    public enum Animation {
        /// 기본 애니메이션 지속 시간
        public static let `default`: TimeInterval = 0.3
    }

    public enum Spacing {
        /// Toast 메시지 하단 여백
        public static let toastBottom: CGFloat = 50
    }
}

//
//  CrashlyticsErrorLogger.swift
//  App
//
//  non-fatal 에러를 Firebase Crashlytics로 원격화한다.
//  Shared는 Firebase-free를 유지하므로 이 어댑터는 App 모듈에 둔다.
//

import FirebaseCrashlytics
import Shared

/// DefaultErrorLogger(로컬 OSLog/파일)를 감싸 Crashlytics 비치명 리포팅을 추가.
struct CrashlyticsErrorLogger: ErrorLogging {
    private let base = DefaultErrorLogger()

    func logError(_ context: ErrorContext) {
        base.logError(context)   // 기존 로컬 로깅 보존

        let crashlytics = Crashlytics.crashlytics()
        crashlytics.setCustomValue(context.feature, forKey: "feature")
        crashlytics.setCustomValue(context.operation, forKey: "operation")
        for (key, value) in context.metadata {
            crashlytics.setCustomValue(value, forKey: key)
        }
        crashlytics.record(error: context.underlyingError)
    }
}

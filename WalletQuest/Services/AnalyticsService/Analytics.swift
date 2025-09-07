import Foundation
import os

protocol Analytics {
    func track(_ event: String, properties: [String: Any]?)
}

final class LoggerAnalytics: Analytics {
    static let shared = LoggerAnalytics()
    private let logger = Logger(subsystem: "WalletQuest", category: "Analytics")

    func track(_ event: String, properties: [String : Any]?) {
        let props = properties ?? [:]
        let json = (try? JSONSerialization.data(withJSONObject: props, options: []))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        logger.info("event=\(event, privacy: .public) props=\(json, privacy: .public)")
    }
}

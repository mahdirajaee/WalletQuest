import Foundation

protocol Analytics {
    func track(_ event: String, properties: [String: Any]?)
}

struct LoggerAnalytics: Analytics {
    func track(_ event: String, properties: [String : Any]?) {
        // placeholder
    }
}


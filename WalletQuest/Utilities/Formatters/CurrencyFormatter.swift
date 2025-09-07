import Foundation

enum CurrencyFormatter {
    static func string(from amount: Double, locale: Locale = .current) -> String {
        let f = NumberFormatter()
        f.locale = locale
        f.numberStyle = .currency
        return f.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }
}


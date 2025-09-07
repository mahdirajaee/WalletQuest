import Foundation

enum MonthFormatter {
    static func yyyymm(from date: Date = Date()) -> String {
        let cal = Calendar(identifier: .gregorian)
        let comps = cal.dateComponents([.year, .month], from: date)
        let y = comps.year ?? 1970
        let m = comps.month ?? 1
        return String(format: "%04d-%02d", y, m)
    }
}

